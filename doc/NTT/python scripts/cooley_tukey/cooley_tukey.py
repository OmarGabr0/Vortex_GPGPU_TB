import math
#########################################################################
###          calculate the ntt using cooley tukey algorithm           ###
#########################################################################
def cooley_tukey_ntt(modulo , psi ):
    even_terms , odd_terms=divide_conquer(input_vector)
    input_size=len(input_vector)
    n=math.ceil((input_size/2)-1)
    z=math.ceil(math.log2(input_size/4)) 
    ntt_out_even= [0]*2
    ntt_out_odd= [0]*2
    new_even= [0]*2
    new_odd= [0]*2
    new_ntt_even=[0]*math.ceil((input_size/4))  
    new_ntt_odd=[0]*math.ceil((input_size/4))  
    combine_matrix_even=[0]*10
    combine_matrix_odd=[0]*10
    final_combine_matrix_even=[0]*1
    final_combine_matrix_odd=[0]*1

    if input_size == 4:
        k=0
    else:   
        k=0
        for i in range(z):
          k= k+ 2**i    
    for x in range(k , n ,  1 ):   
        new_even=even_terms[x]
        new_odd=odd_terms[x]
        print(new_even , new_odd)
        for j in range(2):
            sum_even=0
            sum_odd=0
            for i in range(2):
                mod_psi_pow= ((4*i*j)+(2*i)) % (2*input_size)
                sum_even = sum_even + (pow(psi , mod_psi_pow))*new_even[i]
                sum_odd = sum_odd + (pow(psi , mod_psi_pow))*new_odd[i]
                sum_even=sum_even % modulo    
                sum_odd=sum_odd % modulo 
            ntt_out_even[j]=sum_even
            ntt_out_odd[j]=sum_odd
        print(ntt_out_even ,ntt_out_odd )    
        new_ntt_even[x-k]=ntt_out_even[:] 
        new_ntt_odd[x-k]=ntt_out_odd[:] 

    if input_size==4:
        final_ct_ntt=combine(new_ntt_even[0] , new_ntt_even[0] , psi , input_vector , modulo)
    else:    
        for x in range (int(len(new_ntt_even)/2)):
            combine_matrix_even[x]=combine(new_ntt_even[2*x] , new_ntt_even[2*x+1] , psi , input_vector , modulo)
            combine_matrix_odd[x]=combine(new_ntt_odd[2*x] , new_ntt_odd[2*x+1] , psi , input_vector , modulo)
        print(combine_matrix_even ,combine_matrix_odd )    

        y=math.ceil(math.log2(input_size/4))-1
        for w in range(y):
            for z in range (y):    
                combine_matrix_even[z]=combine(combine_matrix_even[2*z] , combine_matrix_even[2*z+1] , psi , input_vector , modulo)
                combine_matrix_odd[z]=combine(combine_matrix_odd[2*z] , combine_matrix_odd[2*z+1] , psi , input_vector , modulo)
        final_combine_matrix_even=combine_matrix_even[0]   
        final_combine_matrix_odd=combine_matrix_odd[0]
        print( final_combine_matrix_even , final_combine_matrix_odd )
        final_ct_ntt=combine(final_combine_matrix_even , final_combine_matrix_odd , psi , input_vector , modulo)


###################################################################
###                     compine function                        ###
###################################################################
def combine (ntt_in1 , ntt_in2 , psi ,input_vector , modulo):
    n=len(ntt_in1)
    input_size=len(input_vector)
    combine_ntt=[0]*(2*n)
    for j in range(n):   
        mod_psi_pow= ((2*j)+(1)) % (2*input_size)             
        combine_ntt[j]=( ntt_in1[j]+(pow(psi , mod_psi_pow))*ntt_in2[j] ) % modulo
        combine_ntt[j+n]=(ntt_in1[j]-(pow(psi , mod_psi_pow))*ntt_in2[j]) % modulo
    print(combine_ntt)    
    return  combine_ntt 


###################################################################
###              divide the input until reach size 2            ###
###################################################################
def divide_conquer(input_vector):
    input_size=len(input_vector)
    n=math.ceil((input_size/2)-1)
    z=math.ceil(math.log2(input_size/4))  

    even_terms=[0]* ( n ) ##16/2 -1  
    odd_terms=[0] * ( n )   

    even_terms[0]=input_vector[0::2]
    odd_terms[0]=input_vector[1::2]

    if input_size == 4:
        k=0
    else:   
        k=0
        for i in range(z):
          k= k+ 2**i 
        for i in range (k):  
            even_terms[2*i+1]=even_divide(even_terms[i])
            even_terms[2*i+2]=odd_divide(even_terms[i])
        for i in range (k):  
            odd_terms[2*i+1]=even_divide(odd_terms[i])
            odd_terms[2*i+2]=odd_divide(odd_terms[i])
    return even_terms, odd_terms    

###################################################################
###              divide vector into even terms                  ###
###################################################################
def even_divide(even_in):
    even_terms=even_in[0::2]
    return even_terms 
###################################################################
###               divide vector into odd terms                  ###
###################################################################
def odd_divide(odd_in):
    odd_terms =odd_in[1::2]
    return  odd_terms  
###################################################################
###                            main                             ###
###################################################################   
input_vector=[0,2,4,6]
result= cooley_tukey_ntt(7681 , 1925)
print (result)