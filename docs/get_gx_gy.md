# scGROG

Obtain unit, horizontal and linear GRAPPA operators from radial data.
Based on:
```
Nicole Seiberlich, et al (2008) Magnetic Resonance in Medicine
Self-Calibrating GRAPPA Operator Gridding for Radial and Spiral
Trajectories. 59:930-935.
```

This package has only one function: `get_gx_gy.``

## Inputs

The expected input to `get_gx_gy` is `KSpaceData`. A struct with the following fields

* **kSpace** k-space data in this order: nReadout, nRay, (nTime,) nCoil.

* **trajectory** a list of k-space coordinates of the non-cartesian
    k-space trajectory. It is normalized between -0.5 and 0.5 so that you
    have to multiply by the final desired cartesian dimensions in order to
    get actual k-space values.

* **cartesianSize** - an array used to convert the normalized trajectory (above) to final k-space size. Example: [288, 288].

## Outputs

Returns nCoil by nCoil, Gx and Gy matrices.

### Theory

scGROG takes radial data as input. Each ray has a known slope and thus a known horizontal distance `n` and a known vertical distance `m` between adjacent equi-spaced points on the ray.

In terms of grappa operators, we could call the operator that transforms intensities in the direction of the ray "G_ray". We can write it in terms of G_x and G_y where G_x and G_y are the unit grappa operators for transformations in the x and y directions.

These matrices are able to transform signal intensity at one location to the signal intensity at another location like so:

 ```
  -
               *
              /|
         G   / | G_y^m
            *_ |
           /|
          / |
         *_ |

        G_x^n

     G = G_x^n * G_y^m
 ```

For each ray, the steps n and m will be different due to the angle so
let's just consider G_ray for 1 ray:

G_ray = G_x^n_ray * G_y^m_ray

***
If you're not convinced that raising the grappa operator to a power will
do this neat thing, then you should read:

Parallel Magnetic Resonance Imaging Using the GRAPPA Operator Formalism
by Mark A. Griswold et. al.
Magnetic Resonance in Medicine 54:1553?1556 (2005)

***

The first step is to calculate n_ray and m_ray based on the
angle of the ray and the step size between points. In the example pictured
above, n_ray is 1, m_ray is 3.

Once we have n and m for the ray, we can separate the equation via the natural log.
Matrix natural logs have special rules using commutators, but if G_x and G_y
commute (which they do) then that commutator goes to zero and we get back
old-fashioned logarithmic behavior.

```matlab
ln(G_ray) = n_ray * ln(G_x) + m_ray * ln(G_y)
ln(G_ray) = [n_ray,m_ray] * [ln(G_x), ln(G_y)]'
```

And so we can solve for a column matrix with Gx and Gy like so

```matlab
pinv([n_ray, m_ray]) * ln(G_ray) = [ln(G_x), ln(G_y)]'
```

Of course we get the same equations for each ray:

```matlab
pinv([n_ray1, m_ray1]) * ln(G_ray1) = [ln(G_x), ln(G_y)]'
pinv([n_ray2, m_ray2]) * ln(G_ray2) = [ln(G_x), ln(G_y)]'
pinv([n_ray3, m_ray3]) * ln(G_ray3) = [ln(G_x), ln(G_y)]'
```

With linear algebra we know how to take a system of equations and turn them into a matrix.

   1) Turn the stack of ln(G_ray1), ln(G_ray2), etc into a 3D matrix
      called v:

 ```
 -
                /                    \
               | 1-1-1  1-2-1  etc .  |
               | 2-1-1  2-2-1   .  .  |
   v_ray1 =    | 3-1-1  3-2-1   .  .  |
               | 4-1-1  4-2-1   .  .  |
                \                    /


                /                    \
               | 1-1-2  1-2-2  etc .  |
               | 2-1-2  2-2-2   .  .  |
   v_ray2 =    | 3-1-2  3-2-2   .  .  |
               | 4-1-2  4-2-2   .  .  |
                \                    /
 ```

In the above, 1-1-1 means the coefficient in G_ray1 that maps
coil1 to coil1, 4-1-2 means the coefficient in G_ray 2 that maps
coil 4 to coil 1. So v is nCoil x nCoil x nRay

So now `v(row,col,:)` will give you *every* ray's contribution to
the coefficient that maps coil 'row' to coil 'col'.

If we phrase it like that then we get an equation for each
coefficient:

```matlab
v(row,col,:) = all_the_ens * ln(G_x(row,col,:)) +
                  all_the_ems * ln(G_y(row,col,:))
```

`all_the_ens` is just a way to show that we have a 1x1xnRay set
of n coefficients which need to map to each of the nRay
elements of v(row,col,:). Let's combine all the ems and ens

```matlab
NM = [all_the_ens, all_the_ems]
```
so NM is a (2, nRay) matrix.


Now we get

```
v(row,col,:) = NM * [ln(G_x(row,col)); ln(G_y(row,col))]
```

```
pinv(NM) * v(row,col,:) = [ln(G_x(row,col)); ln(G_y(row,col))]
```

And lastly solve for G_x and G_y using the matrix exponent!
