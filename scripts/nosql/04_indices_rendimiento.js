// Ejercicio NoSQL 3: indices y plan de ejecucion (explain)
use("familias_accion");

function resumen(plan) {
  const s = plan.queryPlanner.winningPlan;
  const etapa = (n) => n.inputStage ? n.stage + " > " + etapa(n.inputStage) : n.stage;
  return { etapas: etapa(s.queryPlan || s), docsExaminados: plan.executionStats.totalDocsExamined, devueltos: plan.executionStats.nReturned };
}

db.beneficiarios.dropIndexes();
print("--- 3.1 Sin indice (COLLSCAN)");
printjson(resumen(db.beneficiarios.find({ estado: "ACTIVO", tipo_poblacion: "SISBEN" }).explain("executionStats")));

print("--- 3.2 Creacion de indice compuesto");
printjson(db.beneficiarios.createIndex({ estado: 1, tipo_poblacion: 1 }, { name: "idx_estado_poblacion" }));
printjson(db.beneficiarios.createIndex({ id: 1 }, { unique: true, name: "idx_id_unico" }));

print("--- 3.3 Con indice (IXSCAN)");
printjson(resumen(db.beneficiarios.find({ estado: "ACTIVO", tipo_poblacion: "SISBEN" }).explain("executionStats")));

print("--- 3.4 Indices existentes");
printjson(db.beneficiarios.getIndexes().map(i => i.name));

print("--- 3.5 Validacion de esquema opcional ($jsonSchema) en una coleccion nueva");
db.auditoria.drop();
db.createCollection("auditoria", { validator: { $jsonSchema: { bsonType: "object", required: ["beneficiario_id", "accion"], properties: { beneficiario_id: { bsonType: "int" }, accion: { enum: ["alta", "baja", "cambio"] } } } } });
try { db.auditoria.insertOne({ beneficiario_id: 1, accion: "otro" }); } catch (e) { print("rechazado por validador (codigo " + e.code + "): " + e.message); }
printjson(db.auditoria.insertOne({ beneficiario_id: 1, accion: "alta" }).acknowledged);
