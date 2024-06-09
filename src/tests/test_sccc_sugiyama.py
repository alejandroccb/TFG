import pytest
import random
from sccc_sugiyama import SkewRSConvolutionalCode, SkewRSConvolutionalEncoder, SkewRSSugiyamaDecoder, order_of_automorphism
from sage.all import GF, PolynomialRing, FractionField, SkewPolynomialRing

RANDOM_SEED = 42  # Set a fixed seed for reproducibility

    
def generate_random_error_polynomial(P, length, max_errors):
    """
    Generate a random error polynomial.

    INPUT:
    - P: The skew polynomial ring.
    - length: The length of the error polynomial.
    - max_errors: The maximum number of errors.

    OUTPUT:
    - An error polynomial in the skew polynomial ring P.
    """
    random.seed(RANDOM_SEED)
    field = P.base_ring()

    error_vector = [field(0)] * length
    error_positions = random.sample(range(length), max_errors)
    for pos in error_positions:
        error_vector[pos] = field.random_element()
        
    return P(error_vector)

@pytest.fixture
def setup_skew_rs_code(request):
    """
    Fixture to set up the Skew RS Convolutional Code.

    INPUT:
    - request: The pytest request object containing test parameters.

    OUTPUT:
    - A Skew RS Convolutional Code instance.
    """
    field_size, num_roots = request.param
    F = GF(field_size, 'a')
    a = F.gen()
    R = PolynomialRing(F, 't')
    K = FractionField(R)
    t = R.gen()
    aut = K.hom([(t + a)/t])
    inverse_aut = K.hom([a/(t - 1)])
    P = SkewPolynomialRing(K, aut, 'x')
    x = P.gen()
    alpha = t
    
    # Calculate the order of the automorphism
    automorphism_order = order_of_automorphism(K, aut)
    
    # Ensure num_roots is less than the order of the automorphism
    if num_roots >= automorphism_order:
        num_roots = automorphism_order - 1

    beta = alpha**(-1) * aut(alpha)
    roots = [x - beta]
    for i in range(1, num_roots):
        aut_i = aut**i
        roots.append(x - aut_i(beta))

    C = SkewRSConvolutionalCode(roots=roots, inverse_aut=inverse_aut, alpha=alpha)
    return C

@pytest.mark.parametrize("setup_skew_rs_code", [
    (8, 4),  # GF(8), 4 roots
    (9, 3),  # GF(9), 3 roots
    (16, 4)  # GF(16), 4 roots
], indirect=True)
def test_skew_rs_encoder_decoder(setup_skew_rs_code):
    """
    Test the Skew RS Encoder and Decoder.

    INPUT:
    - setup_skew_rs_code: The Skew RS Convolutional Code fixture.

    OUTPUT:
    - Asserts that the decoded codeword matches the original codeword.
    """
    random.seed(RANDOM_SEED)  # Set a fixed seed for reproducibility
    C = setup_skew_rs_code
    E = SkewRSConvolutionalEncoder(C)
    D = SkewRSSugiyamaDecoder(C)
    
    R = C.polynomial_ring()

    for _ in range(10):  # Perform 10 tests with random errors
        # Generate a random message polynomial
        message = R([C.base_field().random_element() for _ in range(C.dimension())])
        codeword = E.encode(message)  # Encode the message
        
        # Generate a random error polynomial
        error_polynomial = generate_random_error_polynomial(C.polynomial_ring(), C.length(), D.correction_capability())
                
        received_message = codeword + error_polynomial  # Add errors to the codeword
        
        decoded_codeword = D.decode_to_code(received_message)  # Decode the received message

        # Assert that the decoded codeword matches the original codeword
        assert decoded_codeword == codeword, f"Decoding failed for received message: {received_message}, errors: {error_polynomial}"

