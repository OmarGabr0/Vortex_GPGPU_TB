def omega_inverse(modulo , omega ):
    omega_inverse= pow(omega , (modulo-2)) % modulo
    return omega_inverse

def scaling_factor(modulo , in_vector):
    input_size=len(in_vector)
    scaling_factor= pow(input_size , (modulo-2)) % modulo
    return scaling_factor

def cyclic_ntt(modulo , omega , in_vector):
    input_size=len(in_vector)
    ntt_out= [0]*input_size
    for j in range(input_size):
        sum=0
        for i in range(input_size):
            mod_omega_pow= (i*j) % input_size
            sum = sum + (pow(omega , mod_omega_pow))*in_vector[i]
        sum=sum % modulo    
        ntt_out[j]=sum
    return ntt_out
        
def cyclic_intt(modulo , omega , cyclic_ntt_out):
    inv_omega = omega_inverse(modulo, omega)
    scale_factor=scaling_factor(modulo , cyclic_ntt_out)
    n=len(cyclic_ntt_out)
    cyclic_intt_out= [0]*n
    for i in range(n):
        sum=0
        for j in range(n):
            mod_omega_pow= (i*j) % n
            sum = sum + (pow(inv_omega , mod_omega_pow))*cyclic_ntt_out[j]
        sum=(sum*scale_factor) % modulo    
        cyclic_intt_out[i]=sum
    return cyclic_intt_out  


q=7681
omega= 4298
in_vector1=[1,2,3,4]
in_vector2=[5,6,7,8]
ntt1  = cyclic_ntt(q , omega , in_vector1)
ntt2  = cyclic_ntt(q , omega , in_vector2)
innt1 = cyclic_intt(q , omega , ntt1 )
innt2 = cyclic_intt(q , omega , ntt2 )
print ("ntt1" , ntt1)
print ("innt1" ,innt1) 
print ("nnt2" ,ntt2 )
print ("innt2" ,innt2)
y=((3383**(2)))%7681 
print (y)
