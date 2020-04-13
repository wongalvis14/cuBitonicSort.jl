function bitonic_sort_parallel_step(A, n, k, buff, groupsize, boxsize, stride, dir)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if i > k
        return
    end
    groupid = div(i - 1, groupsize)
    groupdir = !dir
    if mod(groupid, 2) == 0
        groupdir = dir
    end

    compInBox = ((mod(i-1, boxsize) + stride) < boxsize)

    if compInBox
        j = i + stride
        this_elem = i <= n ? A[i] : buff[i-n]
        swap_elem = j <= n ? A[j] : buff[j-n]
        if groupdir == (this_elem > swap_elem)
            if i > n
                i = i - n
                j = j - n
                tmp = buff[i]
                buff[i] = buff[j]
                buff[j] = tmp
            elseif j > n
                j = j - n
                tmp = A[i]
                A[i] = buff[j]
                buff[j] = tmp
            else
                tmp = A[i]
                A[i] = A[j]
                A[j] = tmp
            end
        end
    end
    return
end

# dir=true indicates ascending
function bitonic_sort(A, dir=true, max=nothing)
    if max === nothing
        max = typemax(typeof(A[1]))
    end

    n = length(A)

    groupsize = 2
    
    k = nextpow(2, n)

    buff = CuArrays.fill(max, k-n)

    threads = 256
    blocks = cld(k, threads)
    
    # Intuitive representation of the sorter network graph in https://en.wikipedia.org/wiki/Bitonic_sorter
    # group = blue/green, box = red/light red, stride = arrow length

    while groupsize <= k
        stride = div(groupsize, 2)
        boxsize = groupsize
        while stride >= 1
            @cuda threads=threads blocks=blocks bitonic_sort_parallel_step(A, n, k, buff, groupsize, boxsize, stride, dir)

            stride = div(stride, 2)
            boxsize = div(boxsize, 2)
        end

        groupsize = groupsize * 2
    end
    return A
end
