-- Ejercicio NewSQL 1: modelo relacional distribuido en CockroachDB
-- Dominio: beneficiarios del programa Familias en Accion (Puerto Boyaca)
DROP DATABASE IF EXISTS familias_accion_db CASCADE;
CREATE DATABASE familias_accion_db;
USE familias_accion_db;

-- Tablas de referencia (normalizacion de los dominios categoricos)
CREATE TABLE tipos_poblacion (
    codigo      STRING PRIMARY KEY,
    descripcion STRING NOT NULL
);

CREATE TABLE rangos_edad (
    codigo STRING PRIMARY KEY,
    edad_min INT NOT NULL,
    edad_max INT
);

-- Tabla de hechos
CREATE TABLE beneficiarios (
    id                     INT PRIMARY KEY,
    bancarizado            STRING NOT NULL CHECK (bancarizado IN ('SI','NO','ND')),
    discapacidad           STRING NOT NULL CHECK (discapacidad IN ('SI','NO','ND')),
    estado                 STRING NOT NULL CHECK (estado IN ('ACTIVO','NO ACTIVO')),
    etnia                  STRING NOT NULL,
    fecha_inscripcion      DATE,
    genero                 STRING NOT NULL,
    nivel_escolaridad      STRING NOT NULL,
    tipo_documento         STRING NOT NULL,
    tipo_poblacion         STRING NOT NULL REFERENCES tipos_poblacion (codigo),
    rango_beneficio_total  STRING NOT NULL,
    rango_ultimo_beneficio STRING NOT NULL,
    fecha_ultimo_beneficio DATE,
    rango_edad             STRING NOT NULL REFERENCES rangos_edad (codigo),
    titular                STRING NOT NULL CHECK (titular IN ('SI','NO')),
    cantidad_beneficiarios INT NOT NULL CHECK (cantidad_beneficiarios >= 1),
    INDEX idx_estado_poblacion (estado, tipo_poblacion),
    INDEX idx_genero (genero)
);

-- Bitacora de cambios (se usa en el ejercicio de transacciones)
CREATE TABLE auditoria_cambios (
    id_cambio   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    beneficiario_id INT NOT NULL REFERENCES beneficiarios (id) ON DELETE CASCADE,
    campo       STRING NOT NULL,
    valor_anterior STRING,
    valor_nuevo STRING,
    cambiado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO tipos_poblacion VALUES
    ('SISBEN',      'Clasificado por el SISBEN'),
    ('UNIDOS',      'Red Unidos (pobreza extrema)'),
    ('DESPLAZADOS', 'Poblacion victima de desplazamiento'),
    ('ND',          'Sin dato');

INSERT INTO rangos_edad VALUES
    ('06-17', 6, 17), ('18-29', 18, 29), ('30-49', 30, 49), ('50-65', 50, 65), ('>65', 66, NULL);

SHOW TABLES;
