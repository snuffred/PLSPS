using Distributed

addprocs(5)

f = () -> Channel{Int}(1)
worker_ids = workers()
chnls = [ RemoteChannel(f,w) for w in worker_ids ]
@sync for (iw,w) in enumerate(worker_ids)
    @spawnat w begin
        chnl_snd = chnls[iw]
        if iw == 1
            chnl_rcv = chnls[end]
            msg = 2
            println("msg = $msg")
            put!(chnl_snd,msg)
            msg = take!(chnl_rcv)
            println("msg = $msg")
        else
           chnl_rcv = chnls[iw-1]
           msg = take!(chnl_rcv)
           msg += 1
           println("msg = $msg")
           put!(chnl_snd,msg)
        end
    end
end

