from sage.coding.linear_code import AbstractLinearCode
from sage.coding.encoder import Encoder
from sage.coding.decoder import Decoder

# Auxiliar Functions

def left_lcm(poly_list):
    r"""
    Compute the left least common multiple (LCM) of a list of polynomials.

    INPUT:
    - ``poly_list`` -- the list of polynomials for which the left LCM will be calculated.

    OUTPUT:
    - the left LCM of the given list of polynomials.

    Raises:
    - ``ValueError`` -- if the input list is empty.
    """
    if not poly_list:
        raise ValueError("The list of polynomials cannot be empty")
    
    lcm = poly_list[0]
    for poly in poly_list[1:]:
        lcm = lcm.left_lcm(poly)
    
    return lcm

def order_of_automorphism(K, sigma):
    r"""
    Compute the order of the automorphism `sigma` in the field `K`.

    INPUT:
    - ``sigma``: The automorphism whose order is to be computed.
    - ``K``: The field over which the automorphism is defined.

    OUTPUT:
    - ``int``: The order of the automorphism `sigma`.

    RAISES:
    - ``ValueError``: If the order of the automorphism is too large or not found within the first 1000 iterations.
    """
    identity = K.hom([K.gen()])
    current = sigma
    order = 1

    while current != identity:
        current = current * sigma
        order += 1
        
        if order > 1000:
            raise ValueError("The order of the automorphism is too large or not found")

    return order

def jth_norm(gamma, sigma, j):
    r"""
    Compute the j-th norm of the element gamma using the automorphism sigma.

    INPUT:
    - ``gamma``: The element for which the norm is to be calculated.
    - ``sigma``: The automorphism used in the norm calculation.
    - ``j``: The order of the norm.

    OUTPUT:
    - The j-th norm of gamma.

    RAISES:
    - ``ValueError``: If j is negative.
    """
    if j < 0:
        raise ValueError("The order j must be non-negative")

    if j == 0:
        return 1

    norm = gamma
    current = gamma

    for _ in range(1, j):
        current = sigma(current)
        norm *= current

    return norm

def RightED(f, g, inverse_aut):
    r"""
    Perform right Euclidean division.

    INPUT:
    - ``f``: The dividend polynomial.
    - ``g``: The divisor polynomial.
    - ``inverse_aut``: The inverse of the automorphism used for the division.

    OUTPUT:
    - ``c``: The quotient polynomial resulting from the division of f by g.
    - ``r``: The remainder polynomial resulting from the division of f by g.

    DESCRIPTION:
    This function performs the right Euclidean division of polynomials `f` and `g` 
    using the inverse of the automorphism `inverse_aut`. The algorithm iteratively 
    subtracts multiples of `g` from `f` until the degree of the remainder `r` is less 
    than the degree of `g`. The quotient `c` and remainder `r` are updated at each step.

    The function returns the quotient polynomial `c` and the remainder polynomial `r`.
    """
    c = 0
    r = f
    g_list = g.list()
    degree_g = len(g_list) - 1

    r_list = r.list()
    degree_r = len(r_list) - 1
    
    if(degree_g > degree_r):
        return c,r

    
    while g.degree() <= r.degree():
        r_list = r.list()
        degree_r = len(r_list) - 1
        a = (inverse_aut^degree_g)((g_list[degree_g])^(-1) * r_list[degree_r])
        c = c + a * x^(degree_r - degree_g)
        r = r - g * a * x^(degree_r - degree_g)
    
    return c, r

def LeftED(f, g, aut):
    r"""
    Perform left Euclidean division.

    INPUT:
    - ``f``: The dividend polynomial.
    - ``g``: The divisor polynomial.
    - ``aut``: The automorphism used for the division.

    OUTPUT:
    - ``c``: The quotient polynomial resulting from the division of f by g.
    - ``r``: The remainder polynomial resulting from the division of f by g.

    DESCRIPTION:
    This function performs the left Euclidean division of polynomials `f` and `g` 
    using the automorphism `aut`. The algorithm iteratively subtracts multiples of 
    `g` from `f` until the degree of the remainder `r` is less than the degree of `g`. 
    The quotient `c` and remainder `r` are updated at each step.

    The function returns the quotient polynomial `c` and the remainder polynomial `r`.
    """
    c = 0
    r = f
    g_list = g.list()
    degree_g = len(g_list) - 1
    
    r_list = r.list()
    degree_r = len(r_list) - 1
    
    if(degree_g > degree_r):
        return c,r
        
    while g.degree() <= r.degree():
        r_list = r.list()
        degree_r = len(r_list) - 1
        a = r_list[degree_r] * (aut^(degree_r - degree_g))(g_list[degree_g]^(-1))
        c = c + a * x^(degree_r - degree_g)
        r = r - a * x^(degree_r - degree_g) * g
    
    return c, r

def REEA(f, g, inverse_sigma):
    r"""
    Perform the Right Extended Euclidean Algorithm (REEA).

    INPUT:
    - ``f``: The first polynomial.
    - ``g``: The second polynomial.
    - ``inverse_sigma``: The inverse of the automorphism sigma.

    OUTPUT:
    - ``u``: List of coefficients for the Bézout identity such that f*u[i] + g*v[i] = r[i].
    - ``v``: List of coefficients for the Bézout identity such that f*u[i] + g*v[i] = r[i].
    - ``r``: List of remainders, with r[-1] being the greatest common divisor (gcd) of f and g.

    DESCRIPTION:
    This function implements the Right Extended Euclidean Algorithm (REEA) to find
    the Bézout coefficients (u, v) and the greatest common divisor (gcd) of the input
    polynomials f and g. The algorithm proceeds by iteratively performing right
    division with respect to the automorphism defined by inverse_sigma, updating the
    remainders and the Bézout coefficients at each step.

    The algorithm continues until the remainder becomes zero. The last non-zero
    remainder is the gcd of f and g.
    """
    r = [f, g]
    u = [1, 0]
    v = [0, 1]
    i = 1
    
    x = f.parent().gen()

    q = 0
    rem = 0
    
    while r[i] != 0:
        q, rem = RightED(r[i-1], r[i], inverse_sigma)
        r.append(rem)
        u.append(u[i-1] - u[i] * q)
        v.append(v[i-1] - v[i] * q)
        i += 1

    return u, v, r

def normal_basis(automorphism, c, F):
    r"""
    Determine if the matrix constructed with the automorphism and element c
    has a determinant of zero.

    Parameters:
    automorphism (callable): The automorphism sigma applied to elements of F(t).
    c (element of F(t)): An element of the field F(t).

    Returns:
    bool: True if the determinant is zero, False otherwise.
    """
    n = order_of_automorphism(F, automorphism)
    matrix = Matrix(F, n, n, lambda i, j: (automorphism^((i+j)%n))(c))
    det = matrix.determinant()
    
    if det == 0:
        return False
    else:
        return True


class SkewRSConvolutionalCode(AbstractLinearCode):
    r"""
    Implementation of Skew Reed-Solomon Convolutional Codes

    INPUT:
    - ``generator_pol`` -- (default: ``None``) the generator polynomial
        of ``self``. It is the highest-degree monic polynomial which divides every
        polynomial representation of a codeword in ``self``.
    - ``roots`` -- (default: ``None``) a list of roots of the underlying field, 
        whose left common multiple will be the generator polynomial.
    - ``inverse_aut`` -- (default: ``None``) The inverse of the automorphism defined
        in the polynomial ring, since it is an Ore polynomial.
    - ``alpha` -- (default: ``None``) Element of the fraction field such that {alpha,...sigma^{n-1}(alpha) form a normal basis
    """
    def __init__(self, generator_pol=None, roots=None, inverse_aut=None, alpha = None):
        r"""
        Initialize the Skew Reed-Solomon Convolutional Code.

        Check if x^n-1 is divisible by the generator polynomial. 
        This means that the generator polynomial should be a factor of x^n-1. 
        If x^n-1 is not divisible by the generator polynomial, raise an error.
        
        Additionally, if both generator_pol and roots are provided, 
        verify that the left least common multiple (LCM) of the roots is equal to the generator polynomial.
        If the LCM of the roots does not match the generator polynomial, raise an error.

        Also, verify that `inverse_aut` is the inverse of the automorphism, which can be accessed via 
        If it is not, raise an error. The inverse of the automorphism will be helpful for decode.
        """
        if generator_pol is not None and roots is None:
            F = generator_pol.base_ring()
            R = generator_pol.parent()
            n = order_of_automorphism(F, R.twisting_morphism())

            if not generator_pol.left_divides(R.gen()^n - 1):
                raise ValueError("The generator polynomial must divide x^n - 1, where n is the automorphism order")
            self._generator_polynomial = generator_pol
        elif generator_pol is None and roots is not None:
            F = roots[0].base_ring()
            R = roots[0].parent()
            n = order_of_automorphism(F, R.twisting_morphism())
            
            for root in roots:
                if not root.right_divides(R.gen()^n - 1):
                    raise ValueError("All roots must divide x^n - 1, where n is the automorphism order")
        
            self._generator_polynomial = left_lcm(roots)
            
        elif generator_pol is None and roots is not None:
            if left_lcm(roots) != generator_pol:
                raise ValueError("The left lcm of the roots must coincide with the generator polynomial")
            self._generator_polynomial = generator_pol
            self._roots = roots
        else:
            raise ValueError("Either the generator polynomial or the roots must be provided")

        if inverse_aut is not None:
            F = self._generator_polynomial.base_ring()
            aut = R.twisting_morphism()
            if (aut(inverse_aut(F.gen())) != F.gen() or inverse_aut(aut(F.gen())) != F.gen()):
                raise ValueError("The provided inverse_aut is not the inverse of the automorphism")
            self._inverse_automorphism = inverse_aut
        
        if alpha is not None:
            F = self._generator_polynomial.base_ring()
            aut = R.twisting_morphism()
            if not normal_basis(aut,alpha,F):
                raise ValueError("The element alpha must form a normal basis")
            self._alpha = alpha


    
        self._polynomial_ring = self._generator_polynomial.parent()
        self._base_field = self._polynomial_ring.base_ring()
        self._automorphism = R.twisting_morphism()
        self._length = order_of_automorphism(F, self._automorphism)
        self._dimension = self._length - self._generator_polynomial.degree()
        self._designed_distance = self._generator_polynomial.degree() + 1
        
    def _repr_(self):
        r"""
        Return a string representation of the Skew Reed-Solomon Convolutional Code.
        """
        return (f"[{self._length},{self._dimension}] Skew Reed-Solomon Convolutional Code on {self._polynomial_ring}"
                f" with designed distance {self._designed_distance}")
    
    def generator_polynomial(self):
        r"""
        Return the generator polynomial of the code.
        """
        return self._generator_polynomial
    
    def polynomial_ring(self):
        r"""
        Return the polynomial ring of the code.
        """
        return self._polynomial_ring
    
    def base_field(self):
        r"""
        Return the base field of the code.
        """
        return self._base_field
    
    def length(self):
        r"""
        Return the length of the code.
        """
        return self._length
    
    def dimension(self):
        r"""
        Return the dimension of the code.
        """
        return self._dimension
    
    def designed_distance(self):
        r"""
        Return the designed distance of the code.
        """
        return self._designed_distance

    def automorphism(self):
        r"""
        Return the automorphism associated with the skew polynomial ring.
        """
        return self._automorphism
    
    def inverse_automorphism(self):
        r"""
        Return the inverse automorphism associated with the skew polynomial ring.
        """
        return self._inverse_automorphism

class SkewRSConvolutionalEncoder(Encoder):
    r"""
    An encoder for Skew Reed-Solomon Convolutional Codes.

    This encoder implements the encoding process for Skew Reed-Solomon Convolutional Codes
    using a specified SkewRSConvolutionalCode instance.

    INPUT:
    - code: The Skew Reed-Solomon Convolutional Code instance.
    """
    def __init__(self, code):
        r"""
        Initialize the SkewRSConvolutionalEncoder with the given SkewRSConvolutionalCode instance.

        INPUT:
        - code: An instance of `SkewRSConvolutionalCode`.
        """
        if not isinstance(code, SkewRSConvolutionalCode):
            raise ValueError("The provided code must be an instance of SkewRSConvolutionalCode")
        self._code = code
        self._polynomial_ring = code._polynomial_ring
    
    def __repr__(self):
        r"""
        Return a string representation of the SkewRSConvolutionalEncoder.
        """
        return f"SkewRSConvolutionalEncoder for a {self._code}"
    
    def encode(self, message_poly):
        r"""
        Encode the given message polynomial into a codeword using the Skew Reed-Solomon Convolutional Code.

        INPUT:
        - message_poly: A polynomial over the specified ring to be encoded.

        OUTPUT:
        - A codeword as a polynomial over the specified ring.

        RAISES:
        - ``ValueError``: If the degree of `message_poly` exceed code dimension.
        """
        C = self._code
        k = C.dimension()
        
        if message_poly.degree() >= k:
            raise ValueError("Message polynomial degree exceeds code dimension")
        
        codeword_poly = self._generate_codeword(message_poly)
        return codeword_poly
    
    def _generate_codeword(self, message_poly):
        r"""
        Generate the codeword polynomial from the message polynomial.
        This method implements the specific encoding logic for
        Skew Reed-Solomon Convolutional Codes.

        Parameters:
        - message_poly: The message polynomial.

        Returns:
        - The codeword polynomial.
        """
        codeword_poly = message_poly * self._code._generator_polynomial
        return codeword_poly
    
    def unencode(self, codeword_poly):
        r"""
        Unencode the given codeword polynomial to retrieve the original message polynomial.

        INPUT:
        - codeword_poly: A polynomial over the specified ring that is a codeword.

        OUTPUT:
        - The original message polynomial.
        """
        generator_poly = self._code._generator_polynomial
        return codeword_poly // generator_poly

class SkewRSSugiyamaDecoder(Decoder):
    r"""
    Initializes a decoder for Skew Reed-Solomon Convolutional Codes using a Sugiyama-like algorithm.
    
    The decoding process involves:
    1. Computing syndromes from the received codeword.
    2. Deriving the error locator polynomial to identify error positions.
    3. Solving the key equation using the Right Euclidean Extended Algorithm to correct the errors.
    
    INPUT:
    - ``code`` -- The Skew Reed-Solomon Convolutional Code to be decoded.
    """
    def __init__(self, code):
        r"""
        Initialize the instance with a Skew Reed-Solomon Convolutional Code.
    
        INPUT:
        - ``code``: An instance of `SkewRSConvolutionalCode`.
    
        RAISES:
        - ``ValueError``: If `code` is not an instance of `SkewRSConvolutionalCode`.
        """
        if not isinstance(code, SkewRSConvolutionalCode):
            raise ValueError("The provided code must be an instance of SkewRSConvolutionalCode")
        self._correction_capability = floor((code.designed_distance() - 1)/2)
        self._polynomial_ring = code._polynomial_ring
        self._code = code


    def __repr__(self):
        r"""
        Return a string representation of the instance.
    
        OUTPUT:
        - ``str``: A string describing the instance.
        """
        return (f"<A Sugiyama-like algorithm for {self._code} "
                f"with correction capability of {self._correction_capability} errors>")
    
    def correction_capability(self):
        r"""
        Return the correction capability of the code.
        """
        return self._correction_capability


    def decode_to_code(self, word):
        r"""
        Decode the given word to the nearest codeword.
    
        INPUT:
        - ``word``: The word to be decoded. It should be an element of the appropriate
          polynomial ring associated with the code.
    
        OUTPUT:
        - The decoded codeword, which is the nearest codeword to the given word according
          to the decoding algorithm implemented in this class.
    
        DESCRIPTION:
        This method implements a decoding algorithm that takes an input word and decodes
        it to the nearest valid codeword in the Skew Reed-Solomon Convolutional Code.
    
        RAISES:
        - ``ValueError``: If the input word is not valid or cannot be decoded.
        """
        if not self._code._alpha or not self._code.inverse_automorphism():
            raise ValueError("The inverse of the automorphism and the elemente alpha must be provided")

        tau = self.correction_capability()
        aut = self._code.automorphism()
        alpha = self._code._alpha
        beta = alpha^(-1)*aut(alpha)
        n = self._code.length()
        inverse_aut = self._code.inverse_automorphism()
        R = self._polynomial_ring
        x = R.gen()

        # 1. Compute all the syndromes
        y_coefficients = word.list()

        Si = []
        sum = 0
        for i in range(0, 2 * tau):
            aut_i = aut^i
            for j in range(0, n):
                y_j = y_coefficients[j] if j < len(y_coefficients) else 0
                sum += y_j * jth_norm(aut_i(beta), aut, j)
            Si.append(sum)
            sum = 0

        # 2. Compute the syndrome polynomial
        S = 0
        for i in (0..(2 * tau - 1)):
            aut_i = aut^i
            S += aut_i(alpha) * Si[i] * x^i
        

        
        # 3. Apply REEA with x^2tau and S
        u, v, r = REEA(x^(2 * tau), S, inverse_aut)

        for i in (0..len(r) - 1):
            if r[i].degree() < tau:
                I = i
                break
        v_I = v[I]
        r_I = r[I]
        
        # 4. Get the error positions
        error_positions = []
        
        for i in range(0, n):
            if i == 0:
                c, r = RightED(v_I, x - inverse_aut(beta^(-1)), inverse_aut)
            else:
                aut_i = aut^(i - 1)
                _, r = RightED(v_I, x - aut_i(beta^(-1)), inverse_aut)
                
            if r == 0:
                error_positions.append(i)
              
        v_I_list = v_I.list()
        degree_v_I = len(v_I_list) - 1
        
        if degree_v_I > len(error_positions):
            raise ValueError("Key Ecuation Failure, the message can't be decoded")

        # 5. Compute pj
        pj = []
        for j in error_positions:
            c, _ = RightED(v_I, 1 - (aut^j)(beta) * x, inverse_aut)
            pj.append(c)

        # 6. Solve the linear system
        num_eqs = len(error_positions)
        A = Matrix(R, num_eqs, num_eqs)
        b = Matrix(R, num_eqs, 1)

        for i in range(num_eqs):
            for j in range(0, len(error_positions)):
                A[i, j] = (aut^(error_positions[j]))(alpha) * pj[j].list()[i]
            b[i, 0] = r_I.list()[i]

        A_inv = A.inverse()
        e = A_inv * b

        # 7. Compute the errors
        polynomial_error = 0
        for i in range(0, len(error_positions)):
            polynomial_error += e[i][0] * x^(error_positions[i])

        return word - polynomial_error
