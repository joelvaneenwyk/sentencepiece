# SentencePiece Python Wrapper

Python wrapper for SentencePiece. This API will offer the encoding, decoding and training of Sentencepiece.

## Build and Install SentencePiece

For Linux (x64/i686), macOS, and Windows(win32/x64/arm64) environment, you can simply use pip command to install SentencePiece python module.

```sh
pip install sentencepiece
```

To build and install the Python wrapper from source, try the following commands to build and install wheel package.

```sh
git clone https://github.com/google/sentencepiece.git
cd sentencepiece
mkdir build
cd build
cmake .. -DSPM_ENABLE_SHARED=OFF -DCMAKE_INSTALL_PREFIX=./root
make install
cd ../python
python setup.py bdist_wheel
pip install dist/sentencepiece*.whl
```

If you don’t have write permission to the global site-packages directory or don’t want to install into it, please try:

```sh
python setup.py install --user
```

For Windows users who want to build from source, you can build and install the Python wrapper using Visual Studio. First, you need to install the `pwsh.exe` (Powershell 7). Use `winget install --id Microsoft.Powershell --source winget` to install directly. Then open the `Developer PowerShell for VS 2022`, and execute the following commands.

```sh
git clone https://github.com/google/sentencepiece.git
cd sentencepiece
mkdir build
cd build
cmake .. -DSPM_ENABLE_SHARED=OFF -DCMAKE_INSTALL_PREFIX=".\root"
cmake --build . --config Release --target install
cd ../python
pip install wheel
python setup.py bdist_wheel
Get-ChildItem .\dist\sentencepiece*.whl | ForEach-Object { pip install $_.FullName }
```

## Usage

See [this google colab page](https://github.com/google/sentencepiece/blob/master/python/sentencepiece_python_module_example.ipynb) to run sentencepiece interactively.

### Segmentation

```python
>>> import sentencepiece as spm
>>> sp = spm.SentencePieceProcessor(model_file='test/test_model.model')

>>> sp.encode('This is a test')
[284, 47, 11, 4, 15, 400]

>>> sp.encode(['This is a test', 'Hello world'], out_type=int)
[[284, 47, 11, 4, 15, 400], [151, 88, 21, 887]]

>>> sp.encode_as_ids(['This is a test', 'Hello world'])
[[284, 47, 11, 4, 15, 400], [151, 88, 21, 887]]

>>> sp.encode('This is a test', out_type=str)
['▁This', '▁is', '▁a', '▁', 't', 'est']

>>> sp.encode(['This is a test', 'Hello world'], out_type=str)
[['▁This', '▁is', '▁a', '▁', 't', 'est'], ['▁He', 'll', 'o', '▁world']]

>>> sp.encode_as_pieces(['This is a test', 'Hello world'])
[['▁This', '▁is', '▁a', '▁', 't', 'est'], ['▁He', 'll', 'o', '▁world']]

>>> proto = sp.encode('This is a test', out_type='immutable_proto')
>>> for n in proto.pieces:
...     print('piece="{}" surface="{}" id={} begin={} end={}'.format(n.piece, n.surface, n.id, n.begin, n.end))
...
piece="▁This" surface="This" id=284 begin=0 end=4
piece="▁is" surface=" is" id=47 begin=4 end=7
piece="▁a" surface=" a" id=11 begin=7 end=9
piece="▁" surface=" " id=4 begin=9 end=10
piece="t" surface="t" id=15 begin=10 end=11
piece="est" surface="est" id=400 begin=11 end=14

>>> [[x.id for x in proto.pieces], [x.piece for x in proto.pieces], [x.begin for x in proto.pieces], [x.end for x in proto.pieces]]
[[284, 47, 11, 4, 15, 400], ['▁This', '▁is', '▁a', '▁', 't', 'est'], [0, 4, 7, 9, 10, 11], [4, 7, 9, 10, 11, 14]]

>>> proto2 = sp.encode_as_immutable_proto('This is a test')
>>> proto2 == proto
True

>>> for _ in range(10):
...     sp.encode('This is a test', out_type=str, enable_sampling=True, alpha=0.1, nbest_size=-1)
...
['▁', 'T', 'h', 'is', '▁is', '▁a', '▁', 't', 'est']
['▁This', '▁is', '▁', 'a', '▁', 't', 'es', 't']
['▁', 'T', 'h', 'is', '▁', 'is', '▁a', '▁', 't', 'e', 'st']
['▁This', '▁is', '▁a', '▁', 'te', 's', 't']
['▁This', '▁', 'i', 's', '▁a', '▁', 'te', 'st']
['▁This', '▁is', '▁', 'a', '▁', 'te', 's', 't']
['▁T', 'h', 'i', 's', '▁', 'is', '▁a', '▁', 'te', 's', 't']
['▁', 'T', 'h', 'i', 's', '▁', 'is', '▁a', '▁', 't', 'e', 'st']
['▁', 'This', '▁is', '▁a', '▁', 't', 'es', 't']
['▁T', 'h', 'is', '▁', 'i', 's', '▁', 'a', '▁', 'te', 's', 't']

>> sp.nbest_encode('This is a test', nbest_size=5, out_type=str)
[['▁This', '▁is', '▁a', '▁', 't', 'est'],
['▁This', '▁is', '▁a', '▁', 'te', 'st'],
['▁This', '▁is', '▁a', '▁', 'te', 's', 't'],
['▁This', '▁is', '▁a', '▁', 't', 'e', 'st'],
['▁This', '▁is', '▁a', '▁', 't', 'es', 't']]

>>> sp.sample_encode_and_score('This is a test', num_samples=5, alpha=0.1, out_type=str, wor=True)
[(['▁This', '▁', 'i', 's', '▁a', '▁', 'te', 's', 't'], -3.043105125427246),
(['▁This', '▁', 'i', 's', '▁a', '▁', 'te', 'st'], -2.8475849628448486),
(['▁', 'This', '▁is', '▁', 'a', '▁', 'te', 'st'], -3.043248176574707),
(['▁', 'This', '▁is', '▁a', '▁', 't', 'e', 'st'], -2.87727689743042),
(['▁', 'This', '▁', 'i', 's', '▁', 'a', '▁', 't', 'est'], -3.6284031867980957)]

>>> sp.decode([284, 47, 11, 4, 15, 400])
'This is a test'

>>> sp.decode([[284, 47, 11, 4, 15, 400], [151, 88, 21, 887]])
['This is a test', 'Hello world']

>>> proto = sp.decode([284, 47, 11, 4, 15, 400], out_type='immutable_proto')
>>> proto.text
'This is a test'

>>> sp.decode(['▁', 'This', '▁', 'is', '▁a', '▁', 't', 'e', 'st'])
'This is a test'

>>> sp.decode([['▁This', '▁is', '▁a', '▁', 't', 'est'], ['▁He', 'll', 'o', '▁world']])
['This is a test', 'Hello world']

>>> sp.get_piece_size()
1000

>>> sp.id_to_piece(2)
'</s>'

>>> sp.id_to_piece([2, 3, 4])
['</s>', '\r', '▁']

>>> sp.piece_to_id('<s>')
1

>>> sp.piece_to_id(['</s>', '\r', '▁'])
[2, 3, 4]

>>> len(sp)
1000

>>> sp['</s>']
2
```

### Model Training

Training is performed by passing parameters of [spm_train](https://github.com/google/sentencepiece#train-sentencepiece-model) to  SentencePieceTrainer.train() function.

```python
>>> import sentencepiece as spm
>>> spm.SentencePieceTrainer.train(input='test/botchan.txt', model_prefix='m', vocab_size=1000, user_defined_symbols=['foo', 'bar'])
sentencepiece_trainer.cc(73) LOG(INFO) Starts training with :
trainer_spec {
  input: test/botchan.txt
  .. snip
unigram_model_trainer.cc(500) LOG(INFO) EM sub_iter=1 size=1188 obj=10.2839 num_tokens=32182 num_tokens/piece=27.0892
unigram_model_trainer.cc(500) LOG(INFO) EM sub_iter=0 size=1100 obj=10.4269 num_tokens=33001 num_tokens/piece=30.0009
unigram_model_trainer.cc(500) LOG(INFO) EM sub_iter=1 size=1100 obj=10.4069 num_tokens=33002 num_tokens/piece=30.0018
trainer_interface.cc(595) LOG(INFO) Saving model: m.model
trainer_interface.cc(619) LOG(INFO) Saving vocabs: m.vocab
>>>
```

### Training without local filesystem

Sentencepiece trainer can receive any iterable object to feed training sentences. You can also pass a file object (instance with write() method) to emit the output model to any devices. These features are useful to run sentencepiece on environment that have limited access to the local file system (e.g., Google colab.)

```
import urllib.request
import io
import sentencepiece as spm

# Loads model from URL as iterator and stores the model to BytesIO.
model = io.BytesIO()
with urllib.request.urlopen(
    'https://raw.githubusercontent.com/google/sentencepiece/master/data/botchan.txt'
) as response:
  spm.SentencePieceTrainer.train(
      sentence_iterator=response, model_writer=model, vocab_size=1000)

# Serialize the model as file.
# with open('out.model', 'wb') as f:
#   f.write(model.getvalue())

# Directly load the model from serialized model.
sp = spm.SentencePieceProcessor(model_proto=model.getvalue())
print(sp.encode('this is test'))
```
