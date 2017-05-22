import nltk;

def recognize(bytes):
    str = bytes.decode("utf-8")
    tokens = nltk.word_tokenize(str)
    tagged_tokens = nltk.pos_tag(tokens)
    return tagged_tokens
