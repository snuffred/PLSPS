# Basics

## Variables

a = 1

When assigning a variable, the value on the right hand side is not copied into the variable. It is just an association of a name with a value (much like in Python).

We can re-assign a variable, even with a value of another type.

```julia
a = 1
typeof(a)
```

```julia
c::Int = 1
typeof(c)
```

annotate types, not improve performance.

predefined some mathematical constatns inJulia with math Greek letters

## Functions

**end** is necessary.

**return** is optional, value of last line is returned by default.

```julia
function add(a,b)
	return a+b
end
```

## Broadcast syntax

```julia
a = [1,2,3]
b = [4,5,6]
add. (a,b)
```

`a .* b mathematical operators can also be broadcasted`

## Reference

```julia
x = Ref(1)
x[]
```

## Defining function in a shorter way

```julia
add_short(a,b) = a+b
add_short(1,3)
```

## Anonymous(lambda) functions

`add_anonymous = (a,b) -> a+b`

add_anoymous is not a function name, it's a variable associated with a function with no function name

## Higher-order functions

Higher order functions are function can take and/or return other functions.

## Do-blocks

```julia
count([1,2,3,5,32,24) do i
	m = i%2
	m!= 0
end
```

after **do** is the anonymous\*(lambda) functions

## Returning multiple values

```julia
function divrem(a,b)
	c = div(a,b)
	d = rem(a,b)
	(c,d)
end
```

(c,d) is a tuple, note: tuple can't be edited

## Variable number of input arguments

```julia
function showargs(arg...)
	for (i, arg) in enumerate(args)
		println("args[$i] = $ arg")
	end
end
```

## Keyword arguments

```julia
function foo(a,b;c,d)
	print("$a,$b,$c,$d")
end
foo(3,4,d = 3, c =100)
```

## Arrays

### Array literals

```julia
vec = [1,2,3]
mat = [1 2 3 4
	5 6 7 8
	9 10 11 12]
```

### Array initialization

...

### Immutable element type

The type of the elements in the array can't be changed after setted

### Arrays of "any" element type

```julia
a = Any[10,11,12,13]
a[3] = "hi"
```

### Loop

```julia
a = [10, 20, 30 ,40]
for ai in a
	@show ai
end
```

```julia
for i in 1:length(a)
	ai = a[i]
	@show(i, ai)
end
```

```julia
for (i,ai ) in enumerate(a)
	@show(i,ai)
end
```

NB: Arrays indices are 1-based by default in Julia , not like 0 at first in C or Python

## Array views

```julia
v = view(a,:,2)
v[1] = 0
```

---

# Asynchronous

## Task

### Creating Task

```julia
function work(a,b)
	c = a+b
	return c
end
t = Task(work)
```

### Scheduling a Task

`schedule(t)`

**shedule** used to execute task

### Fetching the task result

`fetch(t)`

**fetch** used to get the result from task after schedule

### Tasks run asynchronously

```julia
t = Task(work)
schedule(t)
```

### Yield

**yield**used to interrupted the task

### @async

**@async** used to run code asynchronously, create a task with piece of code such as anonymous function, then schedules it.

### @sync

**sync** used to wait for the block of code executed finished

```julia
@sync begin
	@async sleep(3)
	@async sleep(3)
end
```

## Channles

```julia
chnl  = Channel{Int}()
@async begin
	for i in 1:5
		put!(chnl,i)
	end
	close(chnl)
end
```

Channel is a tunnel to send data between tasks, like FIFO queue which tasks can put and take values.

`take!(chnl)`

### Channels are iterable

```julia
for i in chnl
	@show i
end
```

### Buffered channels

```julia
buffer_size = 2
chnl = Channel{Int}(buffer_size)
```

- `put!` will wait for a `take!` if there is not space left in the channel's buffer.
- `take!` will wait for a `put!` if there is no data to be consumed in the channel.
- `put!` will raise an error if the channel is closed.
- `take!` will raise an error if the channel is closed _and_ empty.

---

# Distributed

`using Distributed`

```julia
addprocs(3) #add 3 processors
procs() # show how processors' status now
workers() # show how workers' status now
nprocs() # show how many processors now
nworkers() # show how many workers now, workers = procs - master= procs -1
myid() #show which processor using now
```

## Executing code remotely

### Function remotecall

```julia
a = ones(2,3)
proc = 2
ftr = remotecall(ones,proc,2,3)
fetch(ftr)
```

execute the function remotely, then fetch it

remotecall can be asynchronous

### @spawnat

```julia
@spawnat proc ones(2,3)
```

equal to create function and remotecall it

@async create a task run asynchronously in local/current process, but @spawnat execute the tasks in remote process. but both of them needed to use **fetch**

### @fetchfrom

**@fetchfrom** is the blocking version of @spawnat, and don't need to fetch it

## Data Movement

## Explicit and Implicit data movement

```julia
proc = 4
a = rand(10,10)
b = rand(10,10)
ftr = remotecall(+, proc, a, b)

fun = () -> a+b
ftr = remotecall(fun,proc)

fetch(ftr)
```

## Data movement with **remote channels**

```julia
fun = () ->Channel{Int}()
chnl = RemoteChannel(fun)

@spawnat 4 being
 	for i in 1:5
		put!(chnl,i)
	end
	close(chnl)
end
```

### Remote channels can be buffered

```julia
buffer_size = 2
owner = 3
fun = ()->Channel{In}(buffer_size)
chnl = RemoteChannel(fun,owner)
```

### Remote channels are also iterable

```julia
for j in chnl
	@show j
end
```

---

# Matrix-matrix multiplication

---

# MPI(point to ponit)

## Minimal MPI Program

```julia
using MPI
MPI.Init()
MPI.Finalize()
```

## Abort

`MPI.Abort(MPI.COMM_WORLD, errorcode)`

## Basic Information

```julia
MPI.Init()
comm = MPI.COMM_WORLD
rank  = MPI.Comm_rank(comm)
nranks = MPI.Comm_size(comm)
host = MPI.Get_processor_name()
```

## Ponit-to-point communication

MPI.Sned and MPI.Recv!: Complete(blocking) directives

MPI.Isned and MPI.Irecv!: incomplete(non-blocking) directives

MPI.Bsend and MPI.Ssend and MPI.Rsend: advanced communicatio modes

### Blocking send and receive

`MPI.Send(sndbuf, comm; dest, tag)`

`_, status = MPI.Recv!(rcvbuf,comm, MPI.Status; source, tag)`

- `sndbuf` data to send.
- `rcvbuf` space to store the incoming data.
- `source` rank of the sender.
- `dest` rank of the receiver.
- `tag`. Might be used to distinguish between different kinds of messages from the same sender to the same receiver (similar to the "subject" in an email).

**ANY_TAG** and **ANY_SOURCE** used to receive sources from any tag/source
`source = MPI.ANY_SOURCE`
`tag = MPI.ANY_TAG`

```julia
_, status = MPI.Recv!(rcvbuf, comm, MPI.Status; source, tag)
status.source
status.tag
```

### MPI.Probe

```julia
status = MPI.Probe(comm, MPI.Status; source, tag)
count = MPI.Get_count(status,T)
```

### Complete operations

MPI.Send MPI.Recv! MPI.Probe are complete operations, meaning that the arguments can be used after the function returns.

### Blocking operations

MPI.Recv! and MPI.Probe are blocking operations, means that they will wait for a matching send.

There are two key competing requirements that face implementations of `MPI_Send`.

1. One might want to minimize synchronization time. This is often achieved by copying the outgoing message in an internal buffer and returning from the `MPI_Send` as soon as possible, without waiting for a matching `MPI_Recv`.
2. One might want to avoid data copies (e.g. for large messages). In this case, one needs to wait for a matching receive and return from the `MPI_Send` when the data has been sent.

### MPI.Sendrecv!

```julia
MPI.Sendrecv!(sndbuf,rcvbuf, comm; dest, source, sendtag, recvtag)
```

### Communication modes

four modes: standard, buffered, synchronous, ready
**MPI.Sned MPI.Bsend MPI.Ssend MPI.Rsend**

### Non-blocking send and receive

**MPI.Isend** **MPI.Irecv!**
Can't sure about underlying operation has finished when these functions return.
**MPI.Wait** be used to wait for completion fo the send and/or receive

- One needs to wait for completion before reseting the send buffer
- One needs to wait for completion before using the receive buffer

### Latency hiding

Using MPI.Isend and MPI.Irecv! can allow one to overlap teh communication and computation, called as **latency-hiding**

### MPI.Iprobe

```julia
ismsg, status = MPI.Iprobe(comm,MPI.Status; source,tag)
```

---

# MPI(colelctives)

## MPI.Barrier()

**MPI.Barrier()** be used to synchronous a group of processes: all processes block until all reached the barrier.

## MPI.Reduce!()

```julia
MPI.Reduce!(sndbuf,recvbuf,op,comm;root)
```

### Reducing multiple values

**MPI.Reduce!()** will reduce the send buffers element by element if more than one element provided

## MPI.Allreduce!()

**MPI.Allreduce!()** can get the result in all processes.

## MPI.Gather!()

**MPI.Gather!()** can let root rank receives all values from all ranks(include root ranks) in a buffer.

```julia
MPI.Gather!(sendbuf,recvbuf,comm;root=0)
```

### MPI.AllGather!()

**MPI.AllGather!()** is a variant of **MPI.Gather!()** which all processes can get the result from all processes.

### MPI.Gatherv!()

```julia
MPI.Gatherv!(sndbuf,rcvbuf,comm;root)
```

**MPI.Gatherv!()** be used to receive different amount of data sent from each ranks.
`MPI.VBuffer()` be used to create a **rcvbuf**(receive buffer) with arguments(length, data type)

## MPI.Scatter

```julia
MPI.Scatter!(sendbuf,recvbuf,comm;root=0)
```

Send the data by cut the data of buffer by rules

## MPI.Bcast!()

```julia
MPI.Bcast!(buf,comm;root)
```

Similar to **MPI.Scatter!()**, but it send the same data to all processes(ranks)

## Communicators

A communicator object has two main purposes:

1. To provide an isolated communication context
2. To define a group of processes

### MPI.Comm_dup()

```julia
newcomm = MPI.Comm_dup(comm)

```

**MPI.Comm_dup()** be used to create a new communicator

### MPI.Comm_split()

```julia
newcomm = MPI.Comm_split(comm,color,key)
```

Two key parameters:

1. color: a kind of rule set by programmer, the result of each rank decided which group of new rank they in in new communicator
2. the key decided the way/method of ranking the each ranks in new communicator

# Jacobi Method

## Serial implementation

```julia
function jacobi(n,niters)
    u = zeros(n+2)
    u[1] = -1
    u[end] = 1
    u_new = copy(u)
    for t in 1:niters
        for i in 2:(n+1)
            u_new[i] = 0.5*(u[i-1]+u[i+1])
        end
        u, u_new = u_new, u
    end
    u
end
```

### Parallelization of the Jacobi method

### Ghost(halo) cells

## Extension to 2D

### Parallelizaiton strategies

- 1D block row partition (each worker handles a subset of consecutive rows and all columns)
- 2D block partition (each worker handles a subset of consecutive rows and columns)
- 2D cyclic partition (each workers handles a subset of alternating rows ans columns)

| Partition | Messages <br> per iteration | Communication <br>per worker | Computation <br>per worker | Ratio communication/<br>computation |
| --------- | --------------------------- | ---------------------------- | -------------------------- | ----------------------------------- |
| 1D block  | 2                           | O(N)                         | N²/P                       | O(P/N)                              |
| 2D block  | 4                           | O(N/√P)                      | N²/P                       | O(√P/N)                             |
| 2D cyclic | 4                           | O(N²/P)                      | N²/P                       | O(1)                                |

- Both 1D and 2D block partitions are potentially scalable if $P<<N$
- The 2D block partition has the lowest communication complexity
- The 1D block partition requires to send less messages (It can be useful if the fixed cost of sending a message is high)
- The best strategy for a given problem size will thus depend on the machine.
- Cyclic partitions are impractical for this application (but they are useful in others)

## The Gauss-Seidel method

remove u_new and only use u from jacobi_method to get The Gauss-Seidel method

### Backwards Gauss-Seidel

iterations over i by reversing the loop order, get method called backward Gauss-Seidel

### Red-black Gauss-Seidel

### Latency hiding

MPI.Isend and MPI.Irecv

# All pairs of shrtest paths

parallelize the Floyd-Warshall algorithm to slove asp problem

## Floyd's sequential algorithm

```julia
function floyd!(C)
  n = size(C,1)
  @assert size(C,2) == n
  for k in 1:n
    for j in 1:n
      for i in 1:n
        @inbounds C[i,j] = min(C[i,j],C[i,k]+C[k,j])
      end
    end
  end
  C
end
```

### Parallelization

The communication over computation cost is

- On the send side: $O(NP)/O(N^2/P) = O(P^2/N)$
- On the receive side $O(N)/O(N^2/P) = O(P/N)$

In summary, the send/computation ratio is $O(P^2/N)$ and the receive/computation ratio is $O(P/N)$. The algorithm is potentially scalable if $P^2<<N$. Note that this is worse than for matrix-matrix multiplication, which is scalable for $P<<N$. I.e., you need a larger problem size in the current algorithm than in matrix-matrix multiplication.

# Gaussian elimination

Gaussian elimination is a method to solve systems of linear equations.

## Serial implementation

```julia
function gaussian_elimination!(B)
    n,m = size(B)
    @inbounds for k in 1:n
        for t in (k+1):m
            B[k,t] =  B[k,t]/B[k,k]
        end
        B[k,k] = 1
        for i in (k+1):n
            for j in (k+1):m
                B[i,j] = B[i,j] - B[i,k]*B[k,j]
            end
            B[i,k] = 0
        end
    end
    B
end
```

### load imbalance

use **row-wise cyclic** partition to fix the problem of load imbalance

### Static vs dynamic load balancing

- **Static load balancing** the work distribution strategy is based on prior information of the algorithm and it does not depend on runtime values.
- **Dynamic load balancing** the work distribution strategy is based on runtime values.

Static load balancing is often used in algorithms for which the load distribution is known in advance and it does not depend on runtime values. On the other hand, dynamic load balancing is often needed in problems in which the work distribution cannot be predicted in advance and depends on runtime values.

### Data dependencies

At iteration $k$,

1. The CPU owning row $k$ does the loop over $t$ to update row $k$.
2. The CPU owning row $k$ sets $B_{kk} = 1$.
3. This CPU sends the red cells in figure above to the other processors.
4. All processors receive the updated values in row $k$ and do the loop over i and j locally (blue cells).

5. The process that owns row $k$ updates its values before sending them.
6. We do not send the full row $k$, only the entries beyond column $k$.
7. We need a cyclic partition to balance the load properly.

# Traveling sales person

## Sequential algorithm(branch and bound)

toal cost is O(N!)

## Serial implementation

## Parallel algorithm

### Option1

each branch -> each process
number of branches = O(N!)

### Option2

fixed number of branches -> each worker
good strategy if don't consider pruning

Performance issues: **Load balance** and **search overhead**

### Option3: Dynamic load balancing with replicated workers model

Choosing **maxhops**, is a trade off between balance and communication overhead.
