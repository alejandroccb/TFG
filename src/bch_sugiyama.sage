from sage.coding.bch_code import BCHCode
from sage.coding.encoder import Encoder
from sage.coding.decoder import Decoder

DEBUG = False

def entries_matrix(i, j, b, X):
    r"""
    Compute the entries for the matrix used in BCH decoding.

    INPUT:
    - ``i``: Row index.
    - ``j``: Column index.
    - ``b``: A parameter used in the calculation.
    - ``X``: A list of values.

    OUTPUT:
    - The computed matrix entry.
    """
    return X[j]^(i + b)

def logger(*args):
    r"""
    Print the concatenated string representation of all arguments.

    INPUT:
    - ``*args``: Variable number of arguments to be printed.
    """
    if DEBUG:
    	print(' '.join(map(str, args)))

class BCHSugiyamaDecoder(Decoder):
    r"""
    Sugiyama decoder for BCH code.

    INPUT:
    - ``code`` -- A code associated with the decoder.
    """
    def __init__(self, code):
        r"""
        Initialize the BCHSugiyamaDecoder with the given BCH code.

        INPUT:
        - ``code``: An instance of `BCHCode`.

        RAISES:
        - ``ValueError``: If `code` is not an instance of `BCHCode`.
        """
        if not isinstance(code, BCHCode):
            raise ValueError("The code has to be an instance of BCHCode")
        super(BCHSugiyamaDecoder, self).__init__(code, code.ambient_space(), "BCHSugiyamaDecoder")
        self._defining_set = code.defining_set()
        self._correction_capability = floor((code.designed_distance() - 1) / 2)
        self._primitive_root = code.primitive_root()
        self._polynomial_ring = code._polynomial_ring

    def _repr_(self):
        r"""
        Return a representation of a decoder for BCH code.
        """
        return "Sugiyama decoder for {}".format(self.code())
    
    def _get_syndrome(self, received):
        """
        Compute the syndrome for a received message

        INPUT:

        - ``received`` -- a callable polynomial representing the received message.

        OUTPUT:
        - A list of syndrome values .
        """
        
        s = []
        a = self._primitive_root
        t = self._correction_capability
        b = self._defining_set[0]
    
        for i in range(b, b + 2*t):
            s.append(received(a^i))
        return s
    
    def correction_capability(self):
        r"""
        Return the correction capability of the code.
        """
        return self._correction_capability


    def decode_to_code(self, word):
        r"""
        Decode the given word to the nearest codeword using Sugiyama's algorithm.

        INPUT:
        - ``word``: The word to be decoded, represented as a polynomial.

        OUTPUT:
        - The decoded codeword, represented as a polynomial.
        """
        t = self._correction_capability

        logger("The code has a correction capability of", t, "errors.")

        # Step 1: Get Syndrome

        S = self._get_syndrome(word)

        logger('List of syndromes:', str(S))

        #Step 2
        x = polygen(self._polynomial_ring.base_ring())
        r_prev = x**(2*t)
        r_act = sum([S[i]*x^i for i in range(len(S))])
        b_prev = 0
        b_act = 1
         
        #Step 3
        while(r_act.degree() >= t or r_prev.degree() < t):
            (quotient,rest) = r_prev.quo_rem(r_act)
            r_prev = r_act
            r_act = rest
            b_sig = b_prev - quotient*b_act
            b_prev = b_act
            b_act = b_sig
        
        # Step 4: Find error locations
        
        b_act_list = b_act.list()
        degree_b_act = len(b_act_list) - 1
        
        # NO ERROR
        if(degree_b_act == 0):
            return word

        a = self._primitive_root
        roots = b_act.roots()
        Xj = [1 / r[0] for r in roots]
        logger("Xj:", Xj)
        nu = len(Xj)
        logger("The number of errors are:", nu)
        kj = [log(xj, a) for xj in Xj]
        logger("Position of the errors:", kj)

        # Step 5: Solve the system of linear equations
        matrix_e = matrix(nu, lambda i, j: entries_matrix(i, j, self._defining_set[0], Xj))

        syn = []

        for i in range(0, nu):
            syn.append(S[i])

        E = matrix_e.solve_right(vector(syn))
        logger("Error magnitudes:", E)

        # Step 6: Compute the error vector

        error_vector = 0

        for i in range(0,nu):
            error_vector = error_vector + E[i]*x^(kj[i])

        logger("Error vector:", E)

        c = word - error_vector
        logger("Codeword in polynomial form: ",c)

        return c
