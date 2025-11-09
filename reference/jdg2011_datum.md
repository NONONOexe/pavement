# Japan Geodetic Datum 2011 (JDG2011) Reference Points

A dataset representing reference points for Japan Geodetic Datum 2011
(JDG2011). This dataset contains system numbers, longitude, latitude,
and corresponding coordinate reference system (CRS) codes for various
geodetic reference points in Japan.

## Usage

``` r
jdg2011_datum
```

## Format

A `data.frame` with 19 rows and 4 columns:

- system_no:

  System number (Roman numeral I-XIX) representing geodetic reference
  zones

- lon:

  Longitude in decimal degrees

- lat:

  Latitude in decimal degrees

- crs:

  Coordinate reference system (CRS) code for reference point

## Examples

``` r
# Show the dataset
jdg2011_datum
#>    system_no      lon lat  crs
#> 1          I 129.5000  33 6669
#> 2         II 131.0000  33 6670
#> 3        III 132.1667  36 6671
#> 4         IV 133.5000  33 6672
#> 5          V 134.3333  36 6673
#> 6         VI 136.0000  36 6674
#> 7        VII 137.1667  36 6675
#> 8       VIII 138.5000  36 6676
#> 9         IX 139.8333  36 6677
#> 10         X 140.8333  40 6678
#> 11        XI 140.2500  44 6679
#> 12       XII 142.2500  44 6680
#> 13      XIII 144.2500  44 6681
#> 14       XIV 142.0000  26 6682
#> 15        XV 127.5000  26 6683
#> 16       XVI 124.0000  26 6684
#> 17      XVII 131.0000  26 6685
#> 18     XVIII 136.0000  20 6686
#> 19       XIX 154.0000  26 6687
```
