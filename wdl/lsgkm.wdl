version 1.0

task lsgkm_train {
    input {
      File posInputFastaFile 
      File negInputFastaFile 
      Int kernelType
      Int L
      Int k
      Int d
    }

    command {
        /software/lsgkm/bin/gkmtrain -T 4 -m 6000 -t ${kernelType} -l ${L} -k ${k} -d ${d} ${posInputFastaFile} ${negInputFastaFile} lsgkmout
    }

    output {
        File modelFile = "lsgkmout.model.txt"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 4
        memory: "8 GB"
    }

    parameter_meta {
        posInputFastaFile: "positive sequence data file in Fasta format"
        negInputFastaFile: "negative sequence data file in Fasta format"
    }
}

task lsgkm_cv {
    input {
      File posInputFastaFile 
      File negInputFastaFile 
      Int kernelType
      Int L
      Int k
      Int d
      Int ncv
    }

    command {
        /software/lsgkm/bin/gkmtrain -T 4 -m 6000 -t ${kernelType} -l ${L} -k ${k} -d ${d} -i 1 -x ${ncv} ${posInputFastaFile} ${negInputFastaFile} lsgkmout
    }

    output {
        File cvpredFile = "lsgkmout.cvpred.1.txt"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 4
        memory: "8 GB"
    }

    parameter_meta {
        posInputFastaFile: "positive sequence data file in Fasta format"
        negInputFastaFile: "negative sequence data file in Fasta format"
        ncv: "number of cross-validation to perform"
    }
}

task lsgkm_weights {
    input {
        File modelFile
        Int L
    }

    command {
        /software/lsgkm/bin/gkmpredict -T 4 /data/${L}mers.fa ${modelFile} lsgkmout.weights.txt
    }

    output {
        File weightsFile = "lsgkmout.weights.txt"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 4
        memory: "8 GB"
    }

    parameter_meta {
        modelFile: "model file from lsgkm_train task"
    }
}
