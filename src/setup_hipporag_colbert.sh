data=$1
extraction_model=$2
available_gpus=$3
syn_thresh=$4
extraction_type=ner

#Running Open Information Extraction
python src/openie_with_retrieval_option_parallel.py --dataset $data --model_name $extraction_model --run_ner --num_passages all #MuSiQue NER
python src/named_entity_extraction_parallel.py --dataset $data --model_name $extraction_model

#Creating ColBERT Graph
python src/create_graph.py --dataset $data --model_name colbertv2 --extraction_model $extraction_model --threshold $syn_thresh --extraction_type $extraction_type --cosine_sim_edges

#Getting Nearest Neighbor Files
CUDA_VISIBLE_DEVICES=$available_gpus python src/colbertv2_knn.py --filename output/kb_to_kb.tsv
CUDA_VISIBLE_DEVICES=$available_gpus python src/colbertv2_knn.py --filename output/query_to_kb.tsv

python src/create_graph.py --dataset $data --model_name colbertv2 --extraction_model $extraction_model --threshold $syn_thresh --create_graph --extraction_type $extraction_type --cosine_sim_edges

#ColBERTv2 Indexing for Entity Retrieval & Ensembling
CUDA_VISIBLE_DEVICES=$available_gpus python3 src/colbertv2_indexing.py \
 --dataset $data \
 --phrase output/$data'_facts_and_sim_graph_phrase_dict_ents_only_lower_preprocess_ner.v3.subset.p' \
 --corpus 'data/'$data'_corpus.json'