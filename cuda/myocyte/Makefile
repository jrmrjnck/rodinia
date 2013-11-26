include ../../common/make.config

NVCC = $(CUDA_DIR)/bin/nvcc

# link objects(binaries) together
myocyte.out:		main.o
	$(NVCC)	main.o \
				-I$(CUDA_DIR)/include \
				-L$(CUDA_DIR)/lib64 \
				-lm -lcuda -lcudart \
                                -o myocyte.out

# compile main function file into object (binary)
main.o:	define.c \
				main.cu \
				work.cu \
				solver.cu \
				embedded_fehlberg_7_8.cu \
				master.cu \
				kernel.cu \
				kernel_ecc.cu \
				kernel_cam.cu \
				kernel_fin.cu \
				work_2.cu \
				solver_2.cu \
				embedded_fehlberg_7_8_2.cu \
				kernel_2.cu \
				kernel_ecc_2.cu \
				kernel_cam_2.cu \
				kernel_fin_2.cu \
				file.c \
				timer.c
	$(NVCC)	main.cu \
				-c -O3 -g

# delete all object files
clean:
	rm *.o *.out output.txt
