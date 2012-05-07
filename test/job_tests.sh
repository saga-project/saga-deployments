
#!/bin/sh

hosts="kraken blacklight"
hosts="kraken blacklight ranger lonestar trestles"

kraken_env="     kraken-gsi.nics.utk.edu              : /nics/a/proj/saga/              : saga/1.6/gcc-4.1.2/"
blacklight_env=" tg-login.blacklight.psc.teragrid.org : /usr/local/packages/tg/csasaga/ : saga/1.6/gcc-4.3.4/"
ranger_env="     tg-login.ranger.tacc.teragrid.org    : /scratch/projects/tg/SAGA/      : saga/1.6/gcc-3.4.6/"
lonestar_env="   tg-login.lonestar.tacc.teragrid.org  : /share1/projects/tg/SAGA/       : saga/1.6/gcc-4.1.2/"
trestles_env="   trestles-login.sdsc.edu              : /home/amerzky/csa               : saga/1.6/gcc-4.1.2/"

for src in $hosts; do

  src_ep=`tmp="${src}_env" ; echo ${!tmp} | cut -f 1 -d ':' | sed -e 's/ //g'`
  src_cl=`tmp="${src}_env" ; echo ${!tmp} | cut -f 2 -d ':' | sed -e 's/ //g'`
  src_sl=`tmp="${src}_env" ; echo ${!tmp} | cut -f 3 -d ':' | sed -e 's/ //g'`

  # gsissh -q $src_ep   ls -l $src_cl/$src_sl/

  for tgt in $hosts; do
    if test $src = $tgt; then
      continue
    fi

    tgt_ep=`tmp="${tgt}_env" ; echo ${!tmp} | cut -f 1 -d ':' | sed -e 's/ //g'`

    printf "$src \t -> $tgt\n"
#   printf "gsissh -q $src_ep \t /bin/sh -c \"$src_cl/$src_sl/bin/saga-run.sh saga-job run gsissh://$tgt_ep/ \t true\"  && echo  ok || echo nok\n"
            gsissh -q $src_ep    /bin/sh -c \"$src_cl/$src_sl/bin/saga-run.sh saga-job run gsissh://$tgt_ep/    true\"  && echo  ok || echo nok
#   printf "gsissh -q $src_ep \t /bin/sh -c \"$src_cl/$src_sl/bin/saga-run.sh saga-job run gsissh://$tgt_ep/ \t false\" && echo nok || echo  ok\n"
            gsissh -q $src_ep    /bin/sh -c \"$src_cl/$src_sl/bin/saga-run.sh saga-job run gsissh://$tgt_ep/    false\" && echo nok || echo  ok
  done
done


