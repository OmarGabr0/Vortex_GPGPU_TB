from cmath import sqrt
import math



def is_primitive_root(psi, q, n):
    # Check if psi^(2*n) ≡ 1 (mod q)

    if pow(psi, 2*n , q) != 1:
        return False 
    
    # Ensure that psi^k % q != 1 for all 1 ≤ k < 2*n
    for k in range(1, 2*n):
        if pow(psi, k, q) == 1:
            return False
    return True

def find_primitive_root(q, n):
    for psi in range(2, q):
        if is_primitive_root(psi, q, n):
            return psi
    return None

def psi_inverse(q , psi ):
    psi_inverse= pow(psi , (q-2)) % q
    return psi_inverse

def main():
    q = int(input("Enter the prime modulus (q): "))
    n = int(input("Enter the polynomial size (n): "))
    psi_inv = find_primitive_root(q, n)
    psi=psi_inverse(q , psi_inv )
    
    if psi:
        print(f"The 2n-th primitive root of unity for prime modulus {q} is: {psi}")
    else:
        print(f"No 2n-th primitive root of unity is found for the given prime modulus {q}")

if __name__ == "__main__":
    main()
