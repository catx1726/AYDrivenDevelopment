import os
import requests
import subprocess
import sys

def get_git_diff():
    # 基准分支从环境变量读取（CI 注入仓库默认分支），兼容 master/main
    base = os.getenv('DEFAULT_BRANCH', 'main')
    diff_stat = subprocess.check_output(['git', 'diff', f'origin/{base}...HEAD', '--stat']).decode('utf-8')
    diff_content = subprocess.check_output(['git', 'diff', f'origin/{base}...HEAD']).decode('utf-8')
    return diff_stat, diff_content

def review():
    diff_stat, diff_content = get_git_diff()
    
    # 获取 PR 环境信息
    pr_body = os.getenv('PR_BODY', '')
    branch_name = os.getenv('BRANCH_NAME', '')
    
    # 过滤逻辑：变更行数过小则跳过
    added_lines = 0
    for line in diff_stat.split('\n'):
        if '+' in line:
            parts = line.split('|')
            if len(parts) > 1:
                try:
                    added_lines += int(parts[-1].strip().split(' ')[0])
                except:
                    pass

    if added_lines < 20:
        print("变更过小，跳过 AI 深度审查。")
        sys.exit(0)

    # 读取标准文档（子库可能未复制母库标准文档：缺失时降级为内置精简清单，而非中断）
    BUILTIN_CHECKLIST = """
## 内置审查清单（母库标准文档缺失时的降级方案）

1. 逻辑错误 / 边界条件 / 潜在 Bug（Blocking）
2. 架构与安全缺陷（Blocking）
3. 可读性与非强制风格建议（前缀 "Nit:"，Non-blocking）
4. PR 是否关联 Issue（Closes #N）并具备 Spec/Plan 文档
"""
    try:
        with open('docs/standards/review-standards/review/reviewer/standard.md', 'r', encoding='utf-8') as f:
            standard = f.read()
        with open('docs/standards/review-standards/review/reviewer/looking-for.md', 'r', encoding='utf-8') as f:
            looking_for = f.read()
    except Exception as e:
        print(f"⚠️ 读取标准文档失败（{e}），降级为内置精简审查清单")
        standard = "依据资深工程师通用标准审查。"
        looking_for = BUILTIN_CHECKLIST
    
    # 构建 Prompt
    prompt = f"""
    你是一名 Google 资深工程师。请依据以下提供的《审查标准》对变更进行代码审查。

    # 上下文信息
    - 关联 PR 内容: {pr_body}
    - 分支名称: {branch_name}

    # 审查标准 (Standard)
    {standard}

    # 审查清单 (Looking For)
    {looking_for}

    # 代码变更 (Diff)
    {diff_content}

    # 要求
    1. 你的职责是提升整体代码健康度，而非追求代码的绝对完美。
    2. 对于严重的架构缺陷、逻辑错误或潜在的 Bug，请明确指出并要求修改（视为 Blocking 评论）。
    3. 对于仅仅是代码质量提升、可读性改进或非强制性的风格建议，请务必在评论前加上 "Nit:" 前缀（视为 Non-blocking 评论）。
    4. **SOP 合规检查**: 检查 PR 是否关联了 Issue (Closes #N)，并检查 docs/superpowers/ 目录下是否存在对应的 Spec/Plan 文档。如果缺失，请在报告中友好提醒。
    5. 你的回复应具有建设性，关注“为什么”而不是“什么”。
    6. 在回复的结尾，必须按照以下格式进行总结：
       - 严重问题 (Blocking): [数量]
       - 轻微建议 (Nit): [数量]
       - 如果没有需要 Blocking 修改的问题，请明确给出你的 "LGTM" 意见。
    7. 回复使用 Markdown 格式。
    """
    
    # 调用 LLM 供应商（OpenAI 兼容端点；默认 DeepSeek，可经 env/repo variables 覆盖）
    api_key = os.getenv('AI_API_KEY') or os.getenv('DEEPSEEK_API_KEY')
    if not api_key:
        print("未配置 AI_API_KEY / DEEPSEEK_API_KEY")
        sys.exit(1)
    base_url = os.getenv('AI_BASE_URL', 'https://api.deepseek.com')
    model = os.getenv('AI_MODEL', 'deepseek-chat')

    response = requests.post(
        f"{base_url}/chat/completions",
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        json={
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.5
        }
    )
    
    if response.status_code == 200:
        with open('review_result.md', 'w', encoding='utf-8') as f:
            f.write(response.json()['choices'][0]['message']['content'])
    else:
        print(f"API 请求失败: {response.text}")
        sys.exit(1)

if __name__ == "__main__":
    review()
