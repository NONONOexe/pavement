\docType{data}
\name{sample_accidents_1}
\alias{sample_accidents_1}
\title{Sample accidents dataset 1}
\format{
A \code{sf} object with 10 rows and 5 columns:
\describe{
  \item{id}{Unique identifier of the accident}
  \item{time}{Hour of the accident (0–23)}
  \item{weather}{Weather condition (factor)}
  \item{severity}{Severity of the accident (factor)}
  \item{geometry}{Point geometry}
}
}
\usage{
sample_accidents_1
}
\description{
A sample dataset containing information about 10 accidents.
The dataset is for demonstration and testing and does not represent
real-world events.
}
\examples{
# Show information about the accidents
sample_accidents_1

# Plot the locations of the accidents
plot(sample_roads$geometry)   # if you have sample_roads
plot(sample_accidents_1$geometry, pch = 4, col = "red", add = TRUE)
}
\keyword{datasets}
