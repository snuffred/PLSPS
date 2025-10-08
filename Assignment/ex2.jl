using MPI
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

if rank == 0
	msg = 1
	println("Rank $rank: Sending message $(msg[1]) to rank $(rank+1)")
	MPI.Send(msg, comm; dest = (rank+1), tag = 0)
	MPI.Recv!(msg, comm; source = (size-1), tag = 1)
elseif rank == (size-1)
	MPI.Recv!(msg, comm; source = (rank-1), tag = 0)
	msg+=1
	MPI.Send(msg, comm; dest = 0, tag = 1)
else
	MPI.Recv!(msg, comm; source = (rank-1), tag = 0)
	msg += 1
	MPI.Send(msg, comm; dest = (rank+1), tag = 0)
end
