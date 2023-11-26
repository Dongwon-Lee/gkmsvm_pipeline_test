version 1.0

task plot_rocpr{
    input {
        File cvpredFile
    }

    command {
        Rscript /software/auc.R ${cvpredFile}
    }

    output {
        File rocprFile= "rocprc.pdf"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 1
        memory: "4 GB"
    }

    parameter_meta {
        cvpredFile: "Cross-validation result file from lsgkm_cv task"
    }
}
