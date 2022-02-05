# mta-ide-search
This resource lets you search for model IDs, DFF and TXD names in all of GTA's .ide files (as well as SAMP.ide).

These files contain information about all models in the game (ID, dff, txd, etc).

For example, you can use this script to find which DFF models use a certain TXD file.

MTA forum topic: [https://forum.mtasa.com/topic/134224-rel-ide-search-tool](https://forum.mtasa.com/topic/134224-rel-ide-search-tool)

Contact (author): Nando#7736 **(Discord)**

# Setup
- Move `ide-search` folder into your server's resources
- Type `start ide-search` in server console
- Use commands /searchide and /listide
- Read more about it [here](/ide-search/server.lua)

# Example
We want to find out which objects use the TXD file used by DYN_ROADBARRIER_5 [1422].

![1](/example_1.png)
![2](/example_2.png)
![3](/example_3.png)