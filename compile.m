addpath(genpath('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/CV/'));
addpath(genpath('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/DataFrameOperator/'));
addpath(genpath('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/mgPlsda'));

res = compiler.build.standaloneApplication('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/main/plsda.m', ...
            'TreatInputsAsNumeric', false,...
            'OutputDir', '/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/standalone');
        

delete('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/standalone/mccExcludedFiles.log');
delete('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/standalone/readme.txt');
delete('/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/standalone/requiredMCRProducts.txt');
