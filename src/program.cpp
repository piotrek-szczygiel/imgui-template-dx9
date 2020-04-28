#include "program.h"

#include <imgui.h>

void program_frame(Program* p) {
    ImGui::Begin("Simple Window");
    ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
    ImGui::SliderFloat("Value", &p->value, 0.0f, 100.0f);
    ImGui::Checkbox("Show Demo", &p->demo);
    ImGui::End();

    if (p->demo) ImGui::ShowDemoWindow(&p->demo);
}
