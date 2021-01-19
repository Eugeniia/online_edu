## Caching the Inverse of a Matrix

## This function creates a special "matrix" object that can cache its inverse

makeCacheMatrix <- function(x = matrix()) {
  m <- NULL
  set <- function(y) { # set the value of the matrix
    x <<- y # caching
    m <<- NULL #caching
  }
  get <- function() x # get the value of the matrix
  setinverse<- function(solve) m <<- solve # set the inverse of the matrix or use inverse()
  getinverse <- function() m # get the inverse of the matrix
  list(set = set, get = get,
       setinverse = setinverse,
       getinverse = getinverse)
}

## This function computes the inverse of the special "matrix" returned by makeCacheMatrix above.

cacheSolve <- function(x, ...) {
  ## Return a matrix that is the inverse of 'x'
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

# Testing
mat <- matrix(rnorm(9), 3, 3); mat; 
solve(mat)
cacheSolve(makeCacheMatrix(mat))
