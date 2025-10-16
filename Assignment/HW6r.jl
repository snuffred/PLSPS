function jacobi_mpi(n, niters)
	u, u_new = init(n, comm)
	load = length(u)-2
	rank = MPI.Comm_rank(comm)
	nranks = MPI.Comm_size(comm)
	nreqs = 2*((rank != 0) + (rank != (nranks-1)))
	reqs = MPI.MultiRequest(nreqs)
	for t in 1:niters
		ireq = 0
		if rank != 0
			neig_rank = rank-1
			u_snd = view(u, 2:2)
			u_rcv = view(u, 1:1)
			dest = neig_rank
			source = neig_rank
			ireq += 1
			MPI.Isend(u_snd, comm, reqs[ireq]; dest)
			ireq += 1
			MPI.Irecv!(u_rcv, comm, reqs[ireq]; source)
		end
		if rank != (nranks-1)
			neig_rank = rank+1
			u_snd = view(u, (load+1):(load+1))
			u_rcv = view(u, (load+2):(load+2))
			dest = neig_rank
			source = neig_rank
			ireq += 1
			MPI.Isend(u_snd, comm, reqs[ireq]; dest)
			ireq += 1
			MPI.Irecv!(u_rcv, comm, reqs[ireq]; source)
		end
		# Upload interior cells
		for i in 3:load
			u_new[i] = 0.5*(u[i-1]+u[i+1])
		end
		# Wait for the communications to finish
		MPI.Waitall(reqs)
		# Update boundaries
		for i in (2, load+1)
			u_new[i] = 0.5*(u[i-1]+u[i+1])
		end
		u, u_new = u_new, u
	end
	return u
end
