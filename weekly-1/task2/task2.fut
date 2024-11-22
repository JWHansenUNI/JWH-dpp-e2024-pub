-- ==
-- entry: main
-- input {[1i32, 2i32, 3i32, 4i32]}
-- output {[1i32, 3i32, 6i32, 10i32]}
-- input {[3i32, 4i32, 8i32, 2i32, 4i32, 3i32, 7i32, 10i32]}
-- output {[3i32, 7i32, 15i32, 17i32, 21i32, 24i32, 31i32, 41i32]}
-- compiled random input { [100000]i32 }
-- compiled random input { [1000000]i32 }
-- compiled random input { [10000000]i32 }
-- compiled random input { [100000000]i32 }

-- ==
-- entry: test_work_efficient
-- input {[2i32, 4i32, 7i32, 11i32]}
-- output {[0i32, 2i32, 6i32, 13i32]}
-- input {[3i32, 4i32, 8i32, 2i32, 4i32, 3i32, 7i32, 10i32]}
-- output {[0i32, 3i32, 7i32, 15i32, 17i32, 21i32, 24i32, 31i32]}
-- compiled random input { [100000]i32 }
-- compiled random input { [1000000]i32 }
-- compiled random input { [10000000]i32 }
-- compiled random input { [100000000]i32 }

-- ==
-- entry: default
-- input {[1i32, 2i32, 3i32, 4i32]}
-- output {[1i32, 3i32, 6i32, 10i32]}
-- input {[3i32, 4i32, 8i32, 2i32, 4i32, 3i32, 7i32, 10i32]}
-- output {[3i32, 7i32, 15i32, 17i32, 21i32, 24i32, 31i32, 41i32]}
-- compiled random input { [100000]i32 }
-- compiled random input { [1000000]i32 }
-- compiled random input { [10000000]i32 }
-- compiled random input { [100000000]i32 }

def ilog2 (x: i64) = 63 - i64.i32 (i64.clz x)

def hillis_steele [n] (xs: [n]i32) : [n]i32 =
    let m = ilog2 n
    in loop xs = copy xs for d in (iota m) do
        let offset = 1 << d in
        map (\i -> if i >= offset then xs[i] + xs[i-offset] else xs[i]) (indices xs)

def work_efficient [n] (xs: [n]i32) : [n]i32 =
    let m = ilog2 n
    let upswept = 
        loop xs = copy xs for d in (((iota m)[::-1]) :> [m]i64) do
            let stride = 1 << (m-d)
            let offset = 1 << (m-d-1)
            let numberofindices = 1 << d
            let indices = 
                map (\i -> (i+1) * stride - 1) (iota numberofindices)
            let values = 
                map (\i -> xs[i] + xs[i-offset]) indices
            in scatter xs indices values

    let upswept[n-1] = 0
    let downswept =
        loop xs = upswept for d in (iota m) do
            let stride = 1 << (m-d)
            let offset = 1 << (m-d-1)
            let numberofindices = 1 << d
            let indices1 = 
                map (\i -> (i+1) * stride - 1) (iota numberofindices)
            let values1 = 
                map (\i -> xs[i] + xs[i-offset]) indices1

            let indices2 =
                map (\i -> i-offset) (indices1)
            let values2 = 
                map (\i -> xs[i+offset]) indices2
                
            let newxs = scatter xs indices1 values1
            in scatter newxs indices2 values2
    in downswept

entry test_work_efficient [n] ( xs: [n]i32 ) : [n]i32 =
    work_efficient xs

entry main [n] ( xs: [n]i32 ) : [n]i32 =
    hillis_steele xs

entry default [n] ( xs: [n]i32 ) : [n]i32 =
    scan (+) 0i32 xs