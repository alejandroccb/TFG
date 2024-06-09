import pytest
import random
from bch_sugiyama import BCHSugiyamaDecoder, BCHCode
from sage.all import GF, PolynomialRing, vector

RANDOM_SEED = 42  # Set a fixed seed for reproducibility

def generate_random_error_vector(R,length, max_errors):
    """
    Generate a random error vector with up to max_errors errors.

    INPUT:
    - R: Polynomial Ring
    - length: The length of the error vector.
    - max_errors: The maximum number of errors.

    OUTPUT:
    - A random error vector.
    """
    field = R.base_ring()
    error_vector = [field(0)] * length
    error_positions = random.sample(range(length), max_errors)
    for pos in error_positions:
        error_vector[pos] = field.random_element()
    return R(error_vector)

@pytest.fixture
def setup_bch_decoder(request):
    """
    Fixture to set up the BCH decoder.

    INPUT:
    - request: The pytest request object containing test parameters.

    OUTPUT:
    - A tuple containing the BCH code and its corresponding decoder.
    """
    field_size, length, designed_distance, offset = request.param
    F = GF(field_size)
    C = BCHCode(F, length, designed_distance, offset=offset)
    D = BCHSugiyamaDecoder(C)
    return C, D

@pytest.mark.parametrize("setup_bch_decoder", [
    (2, 15, 7, 1),  # GF(2), [15,7] BCH Code
    (2, 31, 11, 1),  # GF(2), [31,11] BCH Code
    (2, 63, 21, 1),  # GF(2), [63,21] BCH Code
    (3, 13, 5, 1),  # GF(3), [13,5] BCH Code
    (4, 17, 9, 1)   # GF(4), [16,9] BCH Code
], indirect=True)
def test_decode_to_code(setup_bch_decoder):
    """
    Test the BCH Sugiyama Decoder.

    INPUT:
    - setup_bch_decoder: The BCH code and decoder fixture.

    OUTPUT:
    - Asserts that the decoded codeword matches the original codeword.
    """
    random.seed(RANDOM_SEED)  # Set a fixed seed for reproducibility
    C, D = setup_bch_decoder
    
    R = PolynomialRing(C.base_ring(), 'x')  # Create polynomial ring over the base field

    for _ in range(100):  # Perform 100 tests with random vectors
        # Generate a random message vector
        message = vector(C.base_ring(), [C.base_ring().random_element() for _ in range(C.dimension())])
        codeword = message * C.generator_matrix()  # Encode the message
        polynomial_codeword = R(list(codeword))  # Convert to polynomial form

        # Generate a random error vector
        error_vector = generate_random_error_vector(R,len(codeword), D.correction_capability())
        received_message = polynomial_codeword + error_vector  # Add error to the codeword
        
        decoded_codeword = D.decode_to_code(received_message)  # Decode the received message

        # Assert that the decoded codeword matches the original codeword
        assert decoded_codeword == polynomial_codeword, f"Decoding failed for received message: {received_message}, errors: {error_vector}"

