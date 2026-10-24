// Ejercicio NoSQL 2: aggregation pipeline (equivalente a GROUP BY / JOIN / ventanas de SQL)
use("familias_accion");

print("--- 2.1 $group: beneficiarios por tipo de poblacion y estado");
printjson(db.beneficiarios.aggregate([
  { $group: { _id: { poblacion: "$tipo_poblacion", estado: "$estado" }, total: { $sum: 1 }, personas: { $sum: "$cantidad_beneficiarios" } } },
  { $sort: { "_id.poblacion": 1, "_id.estado": 1 } }
]).toArray());

print("--- 2.2 $match + $group + $project: % bancarizados por rango de edad");
printjson(db.beneficiarios.aggregate([
  { $group: { _id: "$rango_edad", total: { $sum: 1 }, bancarizados: { $sum: { $cond: [{ $eq: ["$bancarizado", "SI"] }, 1, 0] } } } },
  { $project: { _id: 1, total: 1, bancarizados: 1, pct: { $round: [{ $multiply: [{ $divide: ["$bancarizados", "$total"] }, 100] }, 1] } } },
  { $sort: { _id: 1 } }
]).toArray());

print("--- 2.3 $bucket: nucleos por tamanio");
printjson(db.beneficiarios.aggregate([
  { $bucket: { groupBy: "$cantidad_beneficiarios", boundaries: [1, 2, 3, 5, 10, 100], default: "otros", output: { nucleos: { $sum: 1 } } } }
]).toArray());

print("--- 2.4 $group por anio de inscripcion (cadena ISO -> substring)");
printjson(db.beneficiarios.aggregate([
  { $match: { fecha_inscripcion: { $type: "string" } } },
  { $group: { _id: { $substr: ["$fecha_inscripcion", 0, 4] }, inscritos: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).toArray());

print("--- 2.5 $facet: varios resumenes en una sola consulta");
printjson(db.beneficiarios.aggregate([
  { $facet: {
      porGenero: [{ $group: { _id: "$genero", n: { $sum: 1 } } }],
      porEtnia: [{ $group: { _id: "$etnia", n: { $sum: 1 } } }, { $sort: { n: -1 } }, { $limit: 3 }]
  } }
]).toArray());

print("--- 2.6 SAB: $unwind + $group por localidad (sensores)");
use("SAB");
printjson(db.sensores.aggregate([
  { $unwind: "$TipoSensores" },
  { $group: { _id: "$TipoSensores.LOCALIDAD", sensores: { $sum: 1 } } },
  { $sort: { sensores: -1 } }, { $limit: 5 }
]).toArray());
