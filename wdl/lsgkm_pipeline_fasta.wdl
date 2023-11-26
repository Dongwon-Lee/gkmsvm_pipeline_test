version 1.0

import "lsgkm.wdl" as lsgkm
import "utils.wdl" as util

workflow lsgkmTrain {
    String pipeline_ver = 'v0.1'
    
    input {
        File posInputFastaFile 
        File negInputFastaFile 
        Int L = 11
        Int k = 7
        Int d = 3
        Int ncv = 5
    }

    call lsgkm.lsgkm_train { 
        input: 
            posInputFastaFile = posInputFastaFile, 
            negInputFastaFile = negInputFastaFile,
            L = L,
            k = k,
            d = d
    }

    call lsgkm.lsgkm_cv { 
        input: 
            posInputFastaFile = posInputFastaFile, 
            negInputFastaFile = negInputFastaFile,
            L = L,
            k = k,
            d = d,
            ncv = ncv
    }

    call lsgkm.lsgkm_weights { 
        input: 
            modelFile = lsgkm_train.modelFile,
            L = L
    }

    call util.plot_rocpr { 
        input: 
            cvpredFile = lsgkm_cv.cvpredFile
    }

    output {
        File modelFile = lsgkm_train.modelFile
        File cvpredFile = lsgkm_cv.cvpredFile
        File weightsFile = lsgkm_weights.weightsFile
        File rocprFile= plot_rocpr.rocprFile
    }

    meta {
        author: "Dongwon Lee"
        email: "dongwon.lee@childrens.harvard.edu"
        description: "a simple workflow that train lsgkm"
    }
}
