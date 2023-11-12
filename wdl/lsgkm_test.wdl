version 1.0

workflow lsgkmTrain {
    String pipeline_ver = 'v0.1'
    
    input {
        File posInputFastaFile 
        File negInputFastaFile 
        Int ncv = 5
    }

    call lsgkm_train { 
        input: 
            posInputFastaFile = posInputFastaFile, 
            negInputFastaFile = negInputFastaFile
    }

    call lsgkm_cv { 
        input: 
            posInputFastaFile = posInputFastaFile, 
            negInputFastaFile = negInputFastaFile,
            ncv = ncv
    }

    output {
        File modelFile = lsgkm_train.modelFile
        File cvpredFile = lsgkm_cv.cvpredFile
    }

    meta {
        author: "Dongwon Lee"
        email: "dongwon.lee@childrens.harvard.edu"
        description: "a simple workflow that train lsgkm"
    }
}

task lsgkm_train {
    input {
      File posInputFastaFile 
      File negInputFastaFile 
    }

    command {
        /software/lsgkm/bin/gkmtrain -T 4 -m 4000 ${posInputFastaFile} ${negInputFastaFile} lsgkmout
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
      Int ncv
    }

    command {
        /software/lsgkm/bin/gkmtrain -T 4 -m 4000 -x ${ncv} ${posInputFastaFile} ${negInputFastaFile} lsgkmout
    }

    output {
        File cvpredFile = "lsgkmout.cvpred.txt"
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
