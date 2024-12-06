def tw_rom (psi,n,q):
    file_name="tw_rom.txt"
    file=open(file_name , "w")
    for i in range(1 , int((n/2)+1)):
        psi_pow_i=((psi**i)%q)
        print(psi_pow_i)
        file.write(f"{psi_pow_i}\n")
    file.close()   

def main():
    n=int(input("please enter the value of the polynomial size (n): "))
    psi=int(input("please enter the value of primitve root (psi): "))
    q=int(input("please enter the value of modulo (q): "))
    tw_rom(psi,n,q)

if __name__ == "__main__":    
    main()

