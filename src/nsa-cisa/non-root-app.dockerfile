FROM ubuntu:latest
#Update and install the make utility
RUN apt update && apt install -y make
#Copy the source from a folder called “code” and build the application with the make utility
COPY . /code
RUN make /code
#Create a new user (user1) and new group (group1); then switch into that user’s context
RUN useradd user1 && groupadd group1
USER user1:group1
#Set the default entrypoint for the container
CMD /code/app