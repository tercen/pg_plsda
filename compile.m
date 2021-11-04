addpath(genpath('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/CV/'));
addpath(genpath('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/DataFrameOperator/'));
addpath(genpath('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/mgPlsda'));

res = compiler.build.standaloneApplication('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/main/plsda.m', ...
            'TreatInputsAsNumeric', false,...
            'OutputDir', '/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/standalone');
        

delete('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/standalone/mccExcludedFiles.log');
delete('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/standalone/readme.txt');
delete('/media/thiago/EXTRALINUX/Tercen/matlab/pg_plsda/standalone/requiredMCRProducts.txt');
