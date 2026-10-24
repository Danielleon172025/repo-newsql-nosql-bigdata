// Ejercicio NoSQL 1: CRUD y consultas basicas en MongoDB (mongosh / Compass shell)
use("familias_accion");

print("--- 1.1 Total de documentos y un documento de ejemplo");
print(db.beneficiarios.countDocuments());
printjson(db.beneficiarios.findOne({}, { _id: 0 }));

print("--- 1.2 find con filtro y proyeccion: mujeres titulares, activas, de 30-49 anios");
printjson(db.beneficiarios.find(
  { genero: "MUJER", titular: "SI", estado: "ACTIVO", rango_edad: "30-49" },
  { _id: 0, id: 1, tipo_poblacion: 1, rango_beneficio_total: 1 }
).sort({ id: 1 }).limit(3).toArray());

print("--- 1.3 Operadores: personas con discapacidad O etnia indigena");
print(db.beneficiarios.countDocuments({ $or: [{ discapacidad: "SI" }, { etnia: "INDIGENA" }] }));

print("--- 1.4 $in y $gt: nucleos con mas de 3 integrantes en poblacion UNIDOS o DESPLAZADOS");
print(db.beneficiarios.countDocuments({ tipo_poblacion: { $in: ["UNIDOS", "DESPLAZADOS"] }, cantidad_beneficiarios: { $gt: 3 } }));

print("--- 1.5 insertOne / updateOne / deleteOne");
db.beneficiarios.insertOne({ id: 999999, estado: "ACTIVO", genero: "MUJER", tipo_poblacion: "SISBEN", nota: "documento de prueba (esquema flexible)", contacto: { telefono: "3000000000" } });
printjson(db.beneficiarios.findOne({ id: 999999 }, { _id: 0 }));
printjson(db.beneficiarios.updateOne({ id: 999999 }, { $set: { estado: "NO ACTIVO" }, $currentDate: { modificado: true } }).modifiedCount);
printjson(db.beneficiarios.deleteOne({ id: 999999 }).deletedCount);

print("--- 1.6 updateMany: normalizar tipo_documento 'NO DEFINIDO' a 'ND'");
printjson(db.beneficiarios.updateMany({ tipo_documento: "NO DEFINIDO" }, { $set: { tipo_documento: "ND" } }).modifiedCount);

print("--- 1.7 Coleccion SAB.sensores (documentos con arreglo anidado)");
use("SAB");
printjson(db.sensores.find({}, { _id: 0, "TipoSensores": { $slice: 1 } }).toArray());
