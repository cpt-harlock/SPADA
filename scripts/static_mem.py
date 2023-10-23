import numpy as np

def fm_size(n_s, k_s):
    return n_s*(k_s + np.ceil(np.log2(n_s)))/8/1024/1024

def fm_size_es(n_s, k_s):
    return n_s*(k_s + 16 + 8 + 8)/8/1024/1024

def plain_sd(n_s, m, s_c, p):
    return (np.zeros(shape=p.shape) if type(p) not in [int, float] else 0) + n_s*m*s_c/8/1024/1024

def cht_sd(n_s, m, s_c, p):
    return n_s*p*m*(np.ceil(np.log2(n_s)) + np.ceil(np.log2(m)) + s_c)/8/1024/1024

def qcht_sd_exact(n_s, m, s_c, p):
    return n_s*p*m*(np.ceil(np.log2(n_s*m)) - np.ceil(np.log2(n_s*m*p/4)) + s_c)/8/1024/1024

def qcht_sd(n_s, m, s_c, p):
    return n_s*p*m*(np.log2(1/p) + 2 + s_c)/8/1024/1024

def piblt_sd(n_s, m, s_c, p):
    return (n_s*m*(p*s_c + 1))/8/1024/1024

def plain_sd_buckets(mem, n_s, s_c, p):
    return np.floor((mem - fm_size(n_s))/(n_s*s_c/8/1024/1024)) + (np.zeros(shape=p.shape) if type(p) not in [int, float] else 0)

def qcht_sd_buckets(mem, n_s, s_c, p):
    return np.floor((mem - fm_size(n_s))/(n_s*p*(np.log2(1/p) + 2 + s_c)/8/1024/1024))

def piblt_sd_buckets(mem, n_s, s_c, p):
    return np.floor((mem - fm_size(n_s))/(n_s*(p*s_c + 1)/8/1024/1024))

# totals

def tot_hll_cht(flows, m_s, p):
    k_s = 32
    n_s = flows/0.9
    s_c = 5
    m = 2**m_s
    print(f'{fm_size(n_s, k_s) + cht_sd(n_s, m, s_c, p):.3}')

def tot_hll_qcht(flows, m_s, p):
    k_s = 32
    n_s = flows/0.9
    s_c = 5
    m = 2**m_s
    print(f'{fm_size(n_s, k_s) + qcht_sd_exact(n_s, m, s_c, p):.3}')

def tot_ddsketch_cht(flows, m_s, p):
    k_s = 104
    n_s = flows/0.9
    s_c = 8
    m = 2**m_s
    print(f'{fm_size(n_s, k_s) + cht_sd(n_s, m, s_c, p):.3}')

def tot_ddsketch_qcht(flows, m_s, p):
    k_s = 104
    n_s = flows/0.9
    s_c = 8
    m = 2**m_s
    print(f'{fm_size(n_s, k_s) + qcht_sd_exact(n_s, m, s_c, p):.3}')

def tot_ddsketch_piblt(flows, m_s, p):
    k_s = 104
    n_s = flows/0.9
    s_c = 8
    m = 2**m_s
    print(f'{fm_size(n_s, k_s) + piblt_sd(n_s, m, s_c, p):.3}')

def tot_es(flows, m, p):
    k_s = 104
    n_s = flows/0.9
    s_c = 8
    print(f'{fm_size(n_s, k_s) + piblt_sd(n_s, m, s_c, p):.3}')
