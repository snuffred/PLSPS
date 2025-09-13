using Distributed

f = () -> Channel{Int}(1)
worker_ids = workers()
chnls = [RemoteChannel(f, w) for w in worker_ids]
@sync for (iw, w) in enumerate(worker_ids)
    @spawnt w begin
        chnl_snd = chnls[iw]
        if iw == 1
            chnl_rcv = chnls[end]
            msg = 2
            println("msg  = $msg")
            put!(chnl_snd, msg)
        end
    end
end

