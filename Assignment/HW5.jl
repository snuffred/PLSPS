using MPI
MPI.Init()
function matmul_mpi_3!(C, A, B)
	comm = MPI.COMM_WORLD
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	root = 0

	N = size(A, 1)
	load = div(N, P)
	A_local = A
	B_local = zeros(eltype(C), N, load)


	MPI.Scatter!(B, B_local, comm; root)

	C_local = A_local * B_local
	MPI.Gather!(C_local, C, comm; root)
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
