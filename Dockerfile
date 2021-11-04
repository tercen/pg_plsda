#https://github.com/tercen/operator_runtimes
FROM tercen/runtime-matlab-image:r2020b-1

COPY standalone/plsda /mcr/exe/plsda
COPY standalone/run_plsda.sh /mcr/exe/run_plsda.sh