-- Script executado automaticamente pelo entrypoint do container Postgres na primeira inicialização.
-- Observação: O banco principal especificado em POSTGRES_DB (ex: agro) já é criado por padrão.
-- Aqui criamos os bancos adicionais que serão utilizados pelo Airflow e Superset.

CREATE DATABASE airflow;
CREATE DATABASE superset;
