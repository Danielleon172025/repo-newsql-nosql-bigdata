-- Ejercicio NewSQL 4: transacciones ACID, vistas, indices y plan de ejecucion
USE familias_accion_db;

-- 4.1 Transaccion: reactivar un beneficiario y registrar el cambio de forma atomica
SELECT id, estado FROM beneficiarios WHERE estado = 'NO ACTIVO' ORDER BY id LIMIT 1;

BEGIN;
  INSERT INTO auditoria_cambios (beneficiario_id, campo, valor_anterior, valor_nuevo)
  SELECT id, 'estado', estado, 'ACTIVO' FROM beneficiarios WHERE id = (SELECT min(id) FROM beneficiarios WHERE estado = 'NO ACTIVO');
  UPDATE beneficiarios SET estado = 'ACTIVO'
  WHERE id = (SELECT min(id) FROM beneficiarios WHERE estado = 'NO ACTIVO');
COMMIT;

SELECT b.id, b.estado, a.campo, a.valor_anterior, a.valor_nuevo
FROM auditoria_cambios a JOIN beneficiarios b ON b.id = a.beneficiario_id;

-- 4.2 Transaccion revertida: el cambio es visible dentro de la transaccion y desaparece con ROLLBACK
BEGIN;
  UPDATE beneficiarios SET cantidad_beneficiarios = 99 WHERE id = 1;
  SELECT id, cantidad_beneficiarios AS dentro_de_la_transaccion FROM beneficiarios WHERE id = 1;
ROLLBACK;
SELECT id, cantidad_beneficiarios FROM beneficiarios WHERE id = 1;

-- 4.3 Restriccion de integridad: intento de insertar un valor no permitido (debe fallar)
-- INSERT INTO beneficiarios (id, bancarizado, discapacidad, estado, etnia, genero, nivel_escolaridad,
--   tipo_documento, tipo_poblacion, rango_beneficio_total, rango_ultimo_beneficio, rango_edad, titular, cantidad_beneficiarios)
-- VALUES (999999,'TALVEZ','NO','ACTIVO','ND','MUJER','ND','CC','SISBEN','0','0','30-49','SI',1);

-- 4.4 Vista materializada logica para el tablero de seguimiento
CREATE OR REPLACE VIEW v_resumen_poblacion AS
SELECT tipo_poblacion, estado, count(*) AS total,
       sum(cantidad_beneficiarios) AS personas_en_nucleo
FROM beneficiarios
GROUP BY tipo_poblacion, estado;

SELECT * FROM v_resumen_poblacion ORDER BY tipo_poblacion, estado;

-- 4.5 Plan de ejecucion: el indice secundario (estado, tipo_poblacion) evita un full scan
EXPLAIN SELECT count(*) FROM beneficiarios WHERE estado = 'ACTIVO' AND tipo_poblacion = 'SISBEN';

-- 4.6 Particion logica: rangos de la tabla distribuidos por el motor
SHOW RANGES FROM TABLE beneficiarios;
