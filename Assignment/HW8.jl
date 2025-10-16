using MPI
MPI.Init()

function floyd_mpi!(C, comm)
	myC = distribute_input(C, comm)
	floyd_iterations!(myC, comm)
	collect_result!(C, myC, comm)
end

function distribute_input(C, comm)
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	# Communicate problem size
	if rank == 0
		N = size(C, 1)
		if mod(N, P) != 0
			println("N not multiple of P")
			MPI.Abort(comm, -1)
		end
		Nref = Ref(N)
	else
		Nref = Ref(0)
	end
	MPI.Bcast!(Nref, comm; root = 0)
	N = Nref[]
	# Distribute C row-wise
	L = div(N, P)
	myC = similar(C, L, N)
	if rank == 0
		lb = L*rank+1
		ub = L*(rank+1)
		myC[:, :] = view(C, lb:ub, :)
		for dest in 1:(P-1)
			lb = L*dest+1
			ub = L*(dest+1)
			MPI.Send(view(C, lb:ub, :), comm; dest)
		end
	else
		source = 0
		MPI.Recv!(myC, comm; source)
	end
	return myC
end

function input_distance_table(n)
	threshold = 0.1
	mincost = 3
	maxcost = 9
	inf = 10000
	C = fill(inf, n, n)
	for j in 1:n
		for i in 1:n
			if rand() > threshold
				C[i, j] = rand(mincost:maxcost)
			end
		end
		C[j, j] = 0
	end
	C
end

function floyd_iterations!(myC, comm)
	L = size(myC, 1)
	N = size(myC, 2)
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	lb = L*rank+1
	ub = L*(rank+1)
	C_k = similar(myC, N)
	for k in 1:N
		if (lb<=k) && (k<=ub)
			# Send row k to other workers if I have it
			myk = (k-lb)+1
			C_k[:] = view(myC, myk, :)
		end
        root = div(k-1,L)
        MPI.Bcast!(C_k,comm;root)


		# Now, we have the data dependencies and
		# we can do the updates locally
		for j in 1:N
			for i in 1:L
				myC[i, j] = min(myC[i, j], myC[i, k]+C_k[j])
			end
		end
	end
	myC
end

function collect_result!(C, myC, comm)
	L = size(myC, 1)
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	if rank == 0
		lb = L*rank+1
		ub = L*(rank+1)
		C[lb:ub, :] = myC
		for source in 1:(P-1)
			lb = L*source+1
			ub = L*(source+1)
			MPI.Recv!(view(C, lb:ub, :), comm; source)
		end
	else
		dest = 0
		MPI.Send(myC, comm; dest)
	end
	C
end

function floyd!(C)
	n = size(C, 1)
	@assert size(C, 2) == n
	for k in 1:n
		for j in 1:n
			for i in 1:n
				@inbounds C[i, j] = min(C[i, j], C[i, k]+C[k, j])
			end
		end
	end
	C
end
comm = MPI.Comm_dup(MPI.COMM_WORLD)
rank = MPI.Comm_rank(comm)
if rank == 0
	N = 24
else
	N = 0
end
C = input_distance_table(N)
C_par = copy(C)
floyd_mpi!(C_par, comm)
if rank == 0
	C_seq = copy(C)
	floyd!(C_seq)
	if C_seq == C_par
		println("Test passed 🥳")
	else
		println("Test failed")
	end
end
