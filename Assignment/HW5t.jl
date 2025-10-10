using MPI
MPI.Init()
function matmul_mpi_3!(C, A, B)
	comm = MPI.COMM_WORLD
	rank = MPI.Comm_rank(comm)
	P = MPI.Comm_size(comm)
	root = 0
	if rank == root
		N = size(A, 1)
		Nref = Ref(N)
	else
		Nref = Ref(0)
	end
	MPI.Bcast!(Nref, comm; root)
	N = Nref[]
	if rank == root
		myA = A
	else
		myA = zeros(N, N)
	end
	MPI.Bcast!(myA, comm; root)
	L = div(N, P)
	myB = zeros(N, L)
	MPI.Scatter!(B, myB, comm; root)
	myC = myA*myB
	MPI.Gather!(myC, C, comm; root)
	C
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