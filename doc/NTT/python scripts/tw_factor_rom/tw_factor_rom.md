# twiddle factor rom:
```python
def tw_rom (psi,n,q):
    file_name="tw_rom.txt"
    file=open(file_name , "w")
    for i in range(1 , int((n/2)+1)):
        psi_pow_i=((psi**i)%q)
        print(psi_pow_i)
        file.write(f"{psi_pow_i}\n")
    file.close()   
```

```python
def main():
    n=int(input("please enter the value of the polynomial size (n): "))
    psi=int(input("please enter the value of primitve root (psi): "))
    q=int(input("please enter the value of modulo (q): "))
    tw_rom(psi,n,q)
```
```python
if __name__ == "__main__":    
    main()
```    
-this script calculates the values of the primitive root (twiddle factor) after raising it to the powers form 1 to n/2 and then storing in the txt file we will use this txt file to read it in the rom that will contains these values during hardware implementation

-we only calculate half of the values because of the symmetry of the twidlle factor
