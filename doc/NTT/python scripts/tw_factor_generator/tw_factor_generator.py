import sympy as sp

def is_primitive_root(w, q, n):
    """
    Check if a number is a primitive n-th root of unity modulo q.

    Parameters:
    w (int): The number to check.
    q (int): The prime modulus.
    n (int): The polynomial size.

    Returns:
    bool: True if w is a primitive n-th root of unity modulo q, False otherwise.
    """
    # Check if w^n ≡ 1 (mod q)
    if pow(w, n, q) != 1:
        return False 
    
    # Check that w^k % q != 1 for all 1 ≤ k < n
    for k in range(1, n):
        if pow(w, k, q) == 1:
            return False  
    return True

def find_primitive_root(q, n):
    """
    Find all primitive n-th roots of unity modulo q.

    Parameters:
    q (int): The prime modulus.
    n (int): The polynomial size.

    Returns:
    list: A list of primitive n-th roots of unity modulo q.
    """
    omega = []  # Initialize an empty list to store primitive roots
    for w in range(2, q):
        if is_primitive_root(w, q, n):
            omega.append(w)  # Append w to the list if it's a primitive root
    return omega

def main():
    """
    Main function to find and display primitive roots and their corresponding values.
    """
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

if __name__ == "__main__":
    main()
