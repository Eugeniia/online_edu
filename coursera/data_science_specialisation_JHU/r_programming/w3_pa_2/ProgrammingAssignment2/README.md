### Caching the inverse of a matrix

Matrix inversion is usually a costly computation and there may be some
benefit to caching the inverse of a matrix rather than computing it
repeatedly (there are also alternatives to matrix inversion that we will
not discuss here). Here, there are a pair of functions that
cache the inverse of a matrix.

## The first function - caching the inverse of a matrix

The first `makeCacheMatrix` function creates a special "matrix" object and 
caches its inverse. A special "matrix" is a list containing functions that:

1.  set the value of the matrix
2.  get the value of the matrix
3.  set the value of the inverse matrix
4.  get the value of the inverse matrix

<!-- -->

    makeCacheMatrix <- function(x = matrix()) {
            m <- NULL
            set <- function(y) {
                    x <<- y
                    m <<- NULL
            }
            get <- function() x
            setinverse <- function(solve) m <<- solve
            getinverse <- function() m
            list(set = set, get = get,
                 setinverse = setinverse,
                 getinverse = getinverse)
    }

## The second function - computing the inverse of a matrix

The second `cacheSolve` function computes the inverse of the special
"matrix" returned by `makeCacheMatrix` above. If the inverse has
already been calculated (and the matrix has not changed), then
`cacheSolve` retrieves the inverse from the cache.

To compute the inverse of a square matrix the `solve` function is used. 
For example, if `X` is a square invertible matrix, then `solve(X)` 
returns its inverse.

    cacheSolve <- function(x, ...) {
            m <- x$getinverse()
            if(!is.null(m)) {
                    message("getting cached inversed matrix")
                    return(m)
            }
            mat <- x$get()
            m <- solve(mat, ...)
            x$setinverse(m)
            m
    }
