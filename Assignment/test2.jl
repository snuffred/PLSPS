using Distributed
addprocs(5)

f = () -> Channel{Int}(1)
worker_ids = workers()
chnls = [RemoteChannel(f, w) for w in worker_ids]

@sync for (iw, w) in enumerate(worker_ids)
    @spawnat w begin
        println("Worker $w (index $iw) started")
        chnl_snd = chnls[iw]
        if iw == 1
            println("Worker $w: I am the first worker")
            chnl_rcv = chnls[end]
            msg = 2
            println("Worker $w: Initial msg = $msg")
            put!(chnl_snd, msg)
            println("Worker $w: Sent msg, waiting to receive...")
            msg = take!(chnl_rcv)
            println("Worker $w: Final msg = $msg")
        else
            println("Worker $w: I am worker $iw, waiting for message...")
            chnl_rcv = chnls[iw-1]
            msg = take!(chnl_rcv)
            msg += 1
            println("Worker $w: Received and incremented msg = $msg")
            put!(chnl_snd, msg)
            println("Worker $w: Sent msg = $msg")
        end
        println("Worker $w (index $iw) finished")
    end
end