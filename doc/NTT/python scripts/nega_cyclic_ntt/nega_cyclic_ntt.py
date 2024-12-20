def psi_inverse(modulo , psi ):
    psi_inverse= pow(psi , (modulo-2)) % modulo
    return psi_inverse

def scaling_factor(modulo , in_vector):
    input_size=len(in_vector)
    scaling_factor= pow(input_size , (modulo-2)) % modulo
    return scaling_factor

def nega_cyclic_ntt(modulo , psi , in_vector):
    input_size=len(in_vector)
    ntt_out= [0]*input_size
    for j in range(input_size):
        sum=0
        for i in range(input_size):
            mod_psi_pow= ((2*i*j)+i) % (2*input_size)
            sum = sum + (pow(psi , mod_psi_pow))*in_vector[i]
        sum=sum % modulo    
        ntt_out[j]=sum
    return ntt_out
        
def nega_cyclic_intt(modulo , psi , nega_cyclic_ntt_out):
    inv_psi = psi_inverse(modulo, psi)
    scale_factor=scaling_factor(modulo , nega_cyclic_ntt_out)
    n=len(nega_cyclic_ntt_out)
    nega_cyclic_intt_out= [0]*n
    for i in range(n):
        sum=0
        for j in range(n):
            psi_omega_pow= ((2*i*j)+i) % (2*n)
            sum = sum + (pow(inv_psi , psi_omega_pow))*nega_cyclic_ntt_out[j]
        sum=(sum*scale_factor) % modulo    
        nega_cyclic_intt_out[i]=sum
    return nega_cyclic_intt_out  


q=7681
psi= 1925

in_vector1=[0,1,2,3]
in_vector2=[5,6,7,8]
ntt1  = nega_cyclic_ntt(q , psi , in_vector1)
ntt2  = nega_cyclic_ntt(q , psi , in_vector2)
innt1 = nega_cyclic_intt(q , psi , ntt1 )
innt2 = nega_cyclic_intt(q , psi , ntt2 )
print ("ntt1" , ntt1)
print ("innt1" ,innt1) 
print ("nnt2" ,ntt2 )
print ("innt2" ,innt2)

