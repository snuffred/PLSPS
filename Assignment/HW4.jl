using Base: workqueue_for
function matmul_dist_1!(C, A, B)
	m = size(C, 1)
	n = size(C, 2)
	l = size(A, 2)
	@assert size(A, 1) == m
	@assert size(B, 2) == n
	@assert size(B, 1) == l
	z = zero(eltype(C))
	@assert nworkers() == m * n
	iw = 0
	@sync for j in 1:n
		for i in 1:m
			Ai = A[i, :]
			Bj = B[:, j]
			iw += 1
			w = workers()[iw]
			ftr = @spawnat w begin
				Cij = z
				for k in 1:l
					@inbounds Cij += Ai[k] * Bj[k]
				end
				Cij
			end
			@async C[i, j] = fetch(ftr)
		end
	end
	return C
end

function matmul_dist_2!(C, A, B)
	m = size(C, 1)
	n = size(C, 2)
	l = size(A, 2)
	@assert size(A, 1) == m
	@assert size(B, 2) == n
	@assert size(B, 1) == l
	z = zero(eltype(C))
	@assert nworkers() == m
	iw = 0
	@sync for i in 1:m
		Ai = A[i, :]
		iw += 1
		w = workers()[iw]
		ftr = @spawnat w begin
			Ci = fill(z, n)
			for j in 1:n
				for k in 1:l
					@inbounds Ci[j] += Ai[k] * B[k, j]
				end
			end
			Ci
		end
		@async C[i, :] = fetch(ftr)
	end
	return C
end

function matmul_dist_3!(C, A, B)
	m = size(C, 1)
	n = size(C, 2)
	l = size(A, 2)
	@assert size(A, 1) == m
	@assert size(B, 2) == n
	@assert size(B, 1) == l
	@assert mod(m, nworkers()) == 0

	z = zero(eltype(C))
	p = nworkers()
	g = m ÷ p
	iw = 0
	@sync for i in 0:(p-1)
		iw += 1
		w = workers()[iw]
		ftr = @spawnat w begin
			Ci = fill(z, g, n)
			for h in 1:g
				for j in 1:n
					for k in 1:l
						@inbounds C[i*g+h, j] += A[i*g+h, k] * B[k, j]
					end
				end
			end
            Ci
		end
		@async C[(i*g+1):((i+1)*g), :] = fetch(ftr)
	end
	return C
end
