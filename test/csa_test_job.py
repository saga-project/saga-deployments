
import saga
import time
import sys

def is_final (state):

    if state in  (saga.job.job_state.Done,
                  saga.job.job_state.Failed,
                  saga.job.job_state.Canceled,
                  saga.job.job_state.Unknown) :
        return True
    else:
        return False


def main (url, exe) :

    ok  = True
    err = ""
    try:
        jd    = saga.job.description ()
        jd.set_attribute ("Executable", exe)
    
        js    = saga.job.service (url)
        job   = js.create_job (jd)
    
        start = time.time ()
        job.run ()
    
        state = job.get_state ()
    
        print "watching job [ %s ]"  %  str(state)
    
        count = 0
        while not is_final (state) :
    
            job.wait (5)
            state     = job.get_state ()
    
            print "             [ %s ]"%  str(state)
    
            if count > 100 :
                print "give up watching"
                ok  = False
                err = "test timed out.  last job state : %s"  %  state 
                break
    
        if ok :
            if not state == saga.job.job_state.Done :
                ok  = False
                err = "job failed. final job state : %s"  %  state
       
    
    except saga.exception, e :
       ok = False
       for msg in e.get_all_messages () :
           err += msg


    if ok :
        print "[SUCCESS]"
    else :
        print err
        print "[FAILURE]"


if len(sys.argv) < 3:
  sys.exit ('Usage: %s [url] [exe]' % sys.argv[0])

main (sys.argv[1], sys.argv[2])


