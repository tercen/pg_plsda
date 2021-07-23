addpath(genpath('/pg_plsda/CV/'));
addpath(genpath('/pg_plsda/DataFrameOperator/'));
addpath(genpath('/pg_plsda/mgPlsda'));

res = compiler.build.standaloneApplication('/pg_plsda/main/plsda.m', ...
            'TreatInputsAsNumeric', false,...
            'OutputDir', '/pg_plsda/standalone');