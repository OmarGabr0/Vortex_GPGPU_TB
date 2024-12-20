
**Find all primitive n-th roots of unity modulo q.**
-

```python
import sympy as sp
def find_primitive_root(q, n):
    omega = []  # Initialize an empty list to store primitive roots
    for w in range(2, q):
        if is_primitive_root(w, q, n):
            omega.append(w)  # Append w to the list if it's a primitive root
    return omega
```
this function takes all the values in the finite field q and check if this value can be a primitive nth root of unity or not by passing w to the is_primitive_root fn

**Parameters:**

**`q (int):`** The prime modulus.

**`n (int):`** The polynomial size.

**`w:`** primitive n-th root of unity

**Returns:**

list: A list of primitive n-th roots of unity modulo q.



**Check if a number is a primitive n-th root of unity modulo q.**
-
```python
def is_primitive_root(w, q, n):

    # Check if w^n ≡ 1 (mod q)
    if pow(w, n, q) != 1:
        return False 
    
    # Check that w^k % q != 1 for all 1 ≤ k < n
    for k in range(1, n):
        if pow(w, k, q) == 1:
            return False  
    return True
```
this function checks if the passed w is a primitve nth root of unity or not by checking the conditions of the primitve nth root of unity :

**`Check if w^n ≡ 1 (mod q)`**

**`Check that w^k % q != 1 for all 1 ≤ k < n`**


**Parameters:**

**`w (int):`** The number to check.

**`q (int):`** The prime modulus.

**`n (int):`** The polynomial size.

**Returns:**

bool:True if w is a primitive n-th root of unity modulo q, False otherwise.



```python 
def main():
    q = int(input("Enter the prime modulus (q): "))
    n = int(input("Enter the polynomial size (n): "))
    
    # Find the primitive roots of unity
    w = find_primitive_root(q, n)
    psi = []

    # Calculate square roots modulo q
    for i in range(len(w)):
        psi.append(sp.sqrt_mod(w[i], q, all_roots=True))
        if psi == [[], []]:
            psi = 0
            break  

    # Display results
    if w:
        print(f"The n-th primitive root of unity for prime modulus {q} is: {w}")
    else:
        print(f"No n-th primitive root of unity is found for the given prime modulus {q}")
    
    if psi:
        print(f"The 2n-th primitive root of unity for prime modulus {q} is: {psi}")
    else:
        print(f"No 2n-th primitive root of unity is found for the given prime modulus {q}")
```
the main function calls the  find_primitive_root
function and passes to it the value of the modulo (q) and the value of the polynomial size (n)
then it will return all the primitve nth roots of unity in the field of q if the q has no primitive roots it will print that there are no primitive roots found 

after returning the primitive nth roots of unity we can also calculate the primitve 2nth roots of unity as the relation between them is **`𝜓^2≡ 𝑤 mod 𝑞`** so u can calculate **𝜓** by taking modular square root of **w**

**the function which does so is **`(sp.sqrt_mod(w[i], q, all_roots=True))`**:**

 **`all_roots=True`** this is important to set to true as when u are taking squre root there are two values the +ve and the -ve so when this argument is set to true it will return these possible 2 values this means that for every w >> there will be 2 values of the 𝜓 because of this psi is a nested list it will be something like this : psi=[[] []]
 and each [] contains the 2 values i mentioned 

```pyhton
if __name__ == "__main__":

    main()
```    
