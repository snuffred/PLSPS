using MPI
MPI.Init()
function matmul_mpi_3!(C, A, B)
	comm = MPI.COMM_WORLD
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	N = size(A, 1)
	load = div(N, P)

	if rank == 0
		#Send B
		for i in 1:(P-1)
			sndbuf = B
			MPI.Send(sndbuf, comm; dest = i, tag = 0)
		end

		#Send Part of A
		for i in 1:(P-1)
			sndbuf = A[(load*i+1):(load*(i+1)), :]
			MPI.Send(sndbuf, comm; dest = i, tag = 1)
		end

		#Compute first part of A * B in rank0
		C[1:load, :] .= A[1:load, :] * B

		#Receive other ranks' computed results
		for i in 1:(P-1)
			status = MPI.Probe(comm, MPI.Status; source = i, tag = 2)
			count = MPI.Get_count(status, eltypeof(C))
			C_rows = similar(C[(i*load+1):((i+1)*load), :])
			MPI.Recv!(C_rows, comm; source = i, tag = 2)
			C[(i*load+1):((i+1)*load), :] .= C_rows
		end

	else
		#Receive B
		status = MPI.Probe(comm, MPI.Status; source = 0, tag = 0)
		count = MPI.Get_count(status, eltypeof(C))
		B_local = zeros(eltype(c), N, N)
		MPI.Recv!(B_local, comm; source = 0, tag = 0)

		#Receive Part of A
		status = MPI.Probe(comm, MPI.Status; source = 0, tag = 1)
		count = MPI.Get_count(status, eltypeof(C))
		A_local = zeros(eltype(c), load, N)
		MPI.Recv!(A_local, comm; source = 0, tag = 1)

		#Computer the other Part of A in different Rank
		C_local = A_local * B_local

		#Send the result
		MPI.Send(C_local, comm; dest = 0, tag = 2)
	end

	return C
end
function testit(load)
	comm = MPI.COMM_WORLD
	rank = MPI.Comm_rank(comm)
	if rank == 0
		P = MPI.Comm_size(comm)
		N = load * P
	else
		N = 0
	end
	A = rand(N, N)
	B = rand(N, N)
	C = similar(A)
	matmul_mpi_3!(C, A, B)
	return if rank == 0
		if !(C ≈ A * B)
			println("Test failed 😢")
		else
			println("Test passed 🥳")
		end
	end
end
testit(100)
