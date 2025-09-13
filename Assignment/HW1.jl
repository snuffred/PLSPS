function ex1(a)
    maxnumber = a[1]
    pos = 1
    for i in 2:length(a)
        if a[i] > maxnumber
            maxnumber = a[i]
            pos = 1
        end
    end
    return (maxnumber, pos)
end

function ex2(f, g)
    h(x) = f(x) + g(x)
    return h
end

# Exercise 3
using GLMakie

n = 1000
xs = LinRange(-1.7, 0.7, n)
ys = LinRange(-1.2, 1.2, n)

values = [surprise(x, y) for x in xs, y in ys]

heatmap(xs, ys, values)
